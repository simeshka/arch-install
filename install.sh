#!/bin/bash
set -euo pipefail

# ===== Defaults you can override with flags =====
SWAP="4G"
ROOT="20G"
USER="home"
HOST="arch"
DEVICE="/dev/sda"  # change if needed, e.g. /dev/vda or /dev/nvme0n1
ROOTPASS="1234"
USERPASS="1234

# ===== Parse flags =====
while [[ $# -gt 0 ]]; do
  case "$1" in
    --swap)  SWAP="$2"; shift 2 ;;
    --root)  ROOT="$2"; shift 2 ;;
    --user)  USER="$2"; shift 2 ;;
    --host)  HOST="$2"; shift 2 ;;
    --disk)  DEVICE="$2"; shift 2 ;;   # optional: choose disk
    --rtps)  ROOTPASS="$2"; shift 2;;
    --urps)  USERPASS="$2"; shift 2;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

echo "=== Arch Installer ==="
echo "Disk: $DEVICE | Swap: $SWAP | Root: $ROOT | User: $USER | Host: $HOST | Root passwd: $ROOTPASS | User passwd: $USERPASS"
sleep 3

# ---- net + time (ok to fail ping if offline mirror used) ----
ping -c1 archlinux.org || true
timedatectl set-ntp true

# ---- Partition with fdisk (GPT, 4 parts: EFI, swap, root, home) ----
# fdisk accepts +SIZE[M|G] endings. For "use rest": hit Enter on size prompt.
# We'll construct the home size line depending on $HOME.

# shellcheck disable=SC2059
fdisk "$DEVICE" <<FDISK_CMDS
g
n
1

+512M
t
1
n
2

+$SWAP
t
2
19
n
3

+$ROOT
t
3
23
n
4


t
4
42
w
FDISK_CMDS

# ---- Filesystems & mount ----
EFI_PART="${DEVICE}1"
SWAP_PART="${DEVICE}2"
ROOT_PART="${DEVICE}3"
HOME_PART="${DEVICE}4"

mkfs.fat -F32 "$EFI_PART"
mkswap "$SWAP_PART"
mkfs.ext4 -F "$ROOT_PART"
mkfs.ext4 -F "$HOME_PART"

mount "$ROOT_PART" /mnt
mkdir -p /mnt/boot/efi /mnt/home
mount "$EFI_PART" /mnt/boot/efi
mount "$HOME_PART" /mnt/home
swapon "$SWAP_PART"

# ---- Base install ----
pacstrap -K /mnt base linux linux-firmware nano vim networkmanager grub efibootmgr sudo

genfstab -U /mnt >> /mnt/etc/fstab

# ---- Chroot config ----
arch-chroot /mnt /bin/bash <<'CHROOT'
set -euo pipefail
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc
grep -q '^en_US.UTF-8 UTF-8' /etc/locale.gen || echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
CHROOT

# write hostname & hosts from outside so we can use $HOST
echo $HOST > /mnt/etc/hostname
cat > /mnt/etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOST.localdomain $HOST
EOF


# create user with sudo (wheel)
arch-chroot /mnt useradd -m -G wheel -s /bin/bash $USER
# enable sudo for wheel
arch-chroot /mnt sed -i 's|^# %wheel ALL=(ALL:ALL) ALL|%wheel ALL=(ALL:ALL) ALL|' /etc/sudoers

arch-chroot /mnt chpasswd <<EOF
root:$ROOTPASS
EOF
arch-chroot /mnt chpasswd <<EOF
$USER:$USERPASS
EOF


# enable networking & install bootloader
arch-chroot /mnt systemctl enable NetworkManager
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# ---- Done ----
umount -R /mnt
swapoff -a
reboot
