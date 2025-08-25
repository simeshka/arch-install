#!/usr/bin/env bash
# desktop.sh — Arch DE installer via --choice arg

set -euo pipefail

# --- functions ---
pac() { pacman --noconfirm --needed "$@"; }

disable_all_dms() {
  systemctl disable sddm.service gdm.service lightdm.service 2>/dev/null || true
}

enable_dm() {
  systemctl enable "$1"
  systemctl set-default graphical.target
}

install_kde()      { pac -S plasma kde-applications sddm; disable_all_dms; enable_dm sddm.service; }
install_gnome()    { pac -S gnome gnome-extra gdm;       disable_all_dms; enable_dm gdm.service; }
install_cinnamon() { pac -S cinnamon nemo-fileroller lightdm lightdm-gtk-greeter; disable_all_dms; enable_dm lightdm.service; }
install_mate()     { pac -S mate mate-extra lightdm lightdm-gtk-greeter;           disable_all_dms; enable_dm lightdm.service; }
install_xfce()     { pac -S xfce4 xfce4-goodies lightdm lightdm-gtk-greeter;       disable_all_dms; enable_dm lightdm.service; }
install_lxqt()     { pac -S lxqt sddm; disable_all_dms; enable_dm sddm.service; }
install_budgie()   { pac -S budgie-desktop lightdm lightdm-gtk-greeter; disable_all_dms; enable_dm lightdm.service; }
install_deepin()   { pac -S deepin deepin-extra lightdm lightdm-gtk-greeter; disable_all_dms; enable_dm lightdm.service; }

print_menu() {
  cat <<EOF
Choose a desktop with --choice [1-8]:
  1) KDE Plasma
  2) GNOME
  3) Cinnamon
  4) MATE
  5) Xfce
  6) LXQt
  7) Budgie
  8) Deepin
EOF
}

# --- arg parsing ---
CHOICE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --choice) CHOICE="$2"; shift 2 ;;
    -h|--help) print_menu; exit 0 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

if [[ -z "$CHOICE" ]]; then
  print_menu
  exit 1
fi

# --- do the install ---
case "$CHOICE" in
  1) install_kde ;;
  2) install_gnome ;;
  3) install_cinnamon ;;
  4) install_mate ;;
  5) install_xfce ;;
  6) install_lxqt ;;
  7) install_budgie ;;
  8) install_deepin ;;
  *) echo "Invalid choice: $CHOICE"; exit 1 ;;
esac

echo "✅ Desktop environment installed! Reboot to use it."
