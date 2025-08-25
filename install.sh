#!/bin/bash
# Installer by simeshka

# Default values
SWAP="4G"
ROOT="20G"
HOME="100%"
USER="home"
HOST="arch"

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --swap) SWAP="$2"; shift ;;
        --root) ROOT="$2"; shift ;;
        --home) HOME="$2"; shift ;;
        --user) USER="$2"; shift ;;
        --host) HOST="$2"; shift ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
    shift
done

echo "=== Arch Installer ==="
echo "Swap: $SWAP | Root: $ROOT | Home: $HOME | User: $USER | Host: $HOST"
sleep 3

# Networking & clock
ping -c 1 archlinux.org
timedatectl set-ntp true

# Partitioning (auto with sfdisk)
cat <<EOF | sfdisk /dev/sda
label: gpt
,512M,U        # EFI
,$SWAP,S       # Swap
,$ROOT,L       # Root
,$HOME,L       # Home (rest of disk if 100%)
EOF

# Make filesystems
mkfs.fat -F32 /dev/sda1
mkswap /dev/sda2
mkfs.ext4 /dev/sda3
mkfs.ext4 /dev/sda4

# Mount
mount /dev/sda3 /mnt
mkdir -p /mnt/{boot/efi,home}
mount /dev/sda1 /mnt/boot/efi
mount /dev/sda4 /mnt/home
swapon /dev/sda2

# Base system
pacstrap -K /mnt base linux linux-firmware vim nano networkmanager grub efibootmgr

# Fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot setup
arch-chroot /mnt /bin/bash <<CHROOT
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "$HOST" > /etc/hostname
cat >> /etc/hosts <<EOF2
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOST.localdomain $HOST
EOF2

# Root password
echo "Set root password:"
passwd

# User
useradd -m -G wheel -s /bin/bash $USER
echo "Set password for $USER:"
passwd $USER
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Services
systemctl enable NetworkManager

# Bootloader
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch
grub-mkconfig -o /boot/grub/grub.cfg
CHROOT

# Finish
umount -R /mnt
swapoff -a
echo "Arch installed! Rebooting..."
reboot
