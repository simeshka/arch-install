#!/usr/bin/env bash
# desktop.sh — Arch DE installer menu (KDE, GNOME, Cinnamon, MATE, Xfce, LXQt, Budgie, Deepin)
# Run as root or with sudo.

set -euo pipefail

need_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "Please run as root (use sudo)."
    exit 1
  fi
}

pac() { pacman --noconfirm --needed "$@"; }

disable_all_dms() {
  # Disable if present; ignore failures
  systemctl disable sddm.service gdm.service lightdm.service 2>/dev/null || true
}

enable_dm() {
  local svc="$1"
  systemctl enable "$svc"
  # Make sure we boot to a GUI
  systemctl set-default graphical.target
}

install_kde() {
  pac -S plasma kde-applications sddm
  disable_all_dms
  enable_dm sddm.service
}

install_gnome() {
  pac -S gnome gnome-extra gdm
  disable_all_dms
  enable_dm gdm.service
}

install_cinnamon() {
  pac -S cinnamon nemo-fileroller lightdm lightdm-gtk-greeter
  disable_all_dms
  enable_dm lightdm.service
}

install_mate() {
  pac -S mate mate-extra lightdm lightdm-gtk-greeter
  disable_all_dms
  enable_dm lightdm.service
}

install_xfce() {
  pac -S xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
  disable_all_dms
  enable_dm lightdm.service
}

install_lxqt() {
  pac -S lxqt sddm
  disable_all_dms
  enable_dm sddm.service
}

install_budgie() {
  pac -S budgie-desktop lightdm lightdm-gtk-greeter
  disable_all_dms
  enable_dm lightdm.service
}

install_deepin() {
  pac -S deepin deepin-extra lightdm lightdm-gtk-greeter
  disable_all_dms
  enable_dm lightdm.service
}

print_menu() {
  cat <<'EOF'
Choose a desktop to install:
  1) KDE Plasma
  2) GNOME
  3) Cinnamon
  4) MATE
  5) Xfce
  6) LXQt
  7) Budgie
  8) Deepin
  9) Quit
EOF
}

main() {
  need_root
  echo "Syncing packages..."
  pac -Sy

  print_menu
  printf "Enter choice [1-9]: "
  read choice

  case "$choice" in
    1) echo "Installing KDE Plasma...";   install_kde ;;
    2) echo "Installing GNOME...";        install_gnome ;;
    3) echo "Installing Cinnamon...";     install_cinnamon ;;
    4) echo "Installing MATE...";         install_mate ;;
    5) echo "Installing Xfce...";         install_xfce ;;
    6) echo "Installing LXQt...";         install_lxqt ;;
    7) echo "Installing Budgie...";       install_budgie ;;
    8) echo "Installing Deepin...";       install_deepin ;;
    9) echo "Bye!"; exit 0 ;;
    *) echo "Invalid choice."; exit 1 ;;
  esac

  echo "Done! Reboot to the login screen (DM) and pick your session."
}

main "$@"
