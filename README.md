Welcome to arch-install

Currently, there are 2 files in here: install.sh and desktop.sh
install.sh is used to install arch linux from the iso, the arguments are:
--swap [number][K/M/G/T/P] - How much space to give to the swap file.
--root [number][K/M/G/T/P] - How much space to give to the root directory.
--user [string] - Sets the username for the user.
--host [string] - Sets the host name.
--disk /dev/[disk directory] - Directory to write partitions to.
--rtps [string] - Sets the root password.
--urps [string] - Sets the user password.

desktop.sh is used to install the desktop after installing arch linux successfully, the arguments are:
--choice [1-8] - Chooses which desktop to install.
