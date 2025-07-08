#!/bin/sh

DIRS="
books
C
C++
Documents
perl
pics
wallpapers
"

# Remove default directories
rm -rf ~/Desktop ~/Videos ~/Music \
  ~/Templates ~/Pictures 2>/dev/null

# Create directories if they don't exist
for dir in $DIRS; do
  if [ ! -d ~/$dir ]; then
    mkdir ~/$dir
  fi
done

# Clone git repositories if they don't exist
if [ ! -d ~/scripts ]; then
  git clone https://github.com/Jeremy-Mossa/scripts ~/scripts
fi
if [ ! -d ~/dotfiles ]; then
  git clone https://github.com/Jeremy-Mossa/dotfiles ~/dotfiles
fi
if [ ! -d ~/flutter ]; then
  git clone https://github.com/flutter/flutter.git -b stable ~/flutter
fi

# Create symbolic link if it doesn't exist
if [ ! -e ~/downloads ]; then
  ln -s ~/Downloads ~/downloads
fi


# Download Storage repository if it doesn't exist
if [ ! -d ~/Storage ]; then
  wget -O storage.zip \
  https://github.com/Jeremy-Mossa/Storage/archive/main.zip
  unzip storage.zip
  rm storage.zip
  mv Storage-main ~/Storage
fi

if [ ! -d ~/Downloads/scrcpy ]; then
  git clone https://github.com/Genymobile/scrcpy.git ~/Downloads/scrcpy
fi

cp ~/dotfiles/.kshrc ~/.kshrc
cp ~/dotfiles/.xinitrc ~/.xinitrc
cp ~/dotfiles/.Xresources ~/.Xresources
cp ~/dotfiles/.vimrc ~/.vimrc
cp ~/Storage/wallpapers/* ~/wallpapers/

su <<EOF

PKG="
aalib
acpi
adb 
boxes
bubblewrap
clang
cmake
cronie
dillo
dkms
fastboot
fastfetch
feh
ffmpeg
ffmpeg-devel
ffmpeg-libs
figlet
firefox-esr
firejail
fluxbox
fzf
gcc
giflib
gimp
git
gnucash
gtk3-devel
htop
icecat
inxi
java-17-openjdk-devel
ksh
libcgif
libjpeg
libpng
libusb1-devel
linux-firmware
lolcat
meson
mullvad-browser
mullvad-vpn
mupdf
mutt
net-tools
ninja-build
perl-Gtk3
perl-HTTP-Tiny
perl-JSON-PP
pkgconf-pkg-config
prename
python3-numpy
python3-opencv
qmake
rclone
redshift
rtorrent
SDL2-devel
slim
source-foundry-hack-fonts
ssh
ssh-keygen
startx
texlive
tldr
tmux
toilet
vim
vimb
vlc
waydroid
xclip
xdotool
xlockmore
xorg
xorg-x11-font-utils
xorg-x11-server-Xorg
xorg-x11-server-Xvfb
xorg-x11-server-Xwayland
xrdb
xsecurelock
xterm
xz-devel
xz-lzma-compat
yt-dlp
"

for package in $PKG; do
  yes | dnf install "$package"
done

# Add to the render group
usermod -aG render jbm

# Define the udev rules for all major phone/tablet vendors
UDEV_RULES='SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ACTION=="add", RUN+="/usr/sbin/runuser -u jbm -- /home/jbm/scripts/android-detect.sh"
SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", ACTION=="add", RUN+="/usr/sbin/runuser -u jbm -- /home/jbm/scripts/android-detect.sh"
SUBSYSTEM=="usb", ATTR{idVendor}=="12d1", ACTION=="add", RUN+="/usr/sbin/runuser -u jbm -- /home/jbm/scripts/android-detect.sh"
SUBSYSTEM=="usb", ATTR{idVendor}=="2717", ACTION=="add", RUN+="/usr/sbin/runuser -u jbm -- /home/jbm/scripts/android-detect.sh"
SUBSYSTEM=="usb", ATTR{idVendor}=="22d9", ACTION=="add", RUN+="/usr/sbin/runuser -u jbm -- /home/jbm/scripts/android-detect.sh"
SUBSYSTEM=="usb", ATTR{idVendor}=="2d95", ACTION=="add", RUN+="/usr/sbin/runuser -u jbm -- /home/jbm/scripts/android-detect.sh"
SUBSYSTEM=="usb", ATTR{idVendor}=="2a70", ACTION=="add", RUN+="/usr/sbin/runuser -u jbm -- /home/jbm/scripts/android-detect.sh"
SUBSYSTEM=="usb", ATTR{idVendor}=="22b8", ACTION=="add", RUN+="/usr/sbin/runuser -u jbm -- /home/jbm/scripts/android-detect.sh"
SUBSYSTEM=="usb", ATTR{idVendor}=="1004", ACTION=="add", RUN+="/usr/sbin/runuser -u jbm -- /home/jbm/scripts/android-detect.sh"
SUBSYSTEM=="usb", ATTR{idVendor}=="054c", ACTION=="add", RUN+="/usr/sbin/runuser -u jbm -- /home/jbm/scripts/android-detect.sh"
SUBSYSTEM=="usb", ATTR{idVendor}=="0bb4", ACTION=="add", RUN+="/usr/sbin/runuser -u jbm -- /home/jbm/scripts/android-detect.sh"
SUBSYSTEM=="usb", ATTR{idVendor}=="0b05", ACTION=="add", RUN+="/usr/sbin/runuser -u jbm -- /home/jbm/scripts/android-detect.sh"
SUBSYSTEM=="usb", ATTR{idVendor}=="17ef", ACTION=="add", RUN+="/usr/sbin/runuser -u jbm -- /home/jbm/scripts/android-detect.sh"
SUBSYSTEM=="usb", ATTR{idVendor}=="19d2", ACTION=="add", RUN+="/usr/sbin/runuser -u jbm -- /home/jbm/scripts/android-detect.sh"
SUBSYSTEM=="usb", ATTR{idVendor}=="1949", ACTION=="add", RUN+="/usr/sbin/runuser -u jbm -- /home/jbm/scripts/android-detect.sh"
SUBSYSTEM=="usb", ATTR{idVendor}=="0489", ACTION=="add", RUN+="/usr/sbin/runuser -u jbm -- /home/jbm/scripts/android-detect.sh"'

UDEV_FILE="/etc/udev/rules.d/99-android-detect.rules"

# Check if the rules already exist in the file
if [ -f "$UDEV_FILE" ] && echo "$UDEV_RULES" | grep -Fx -f - "$UDEV_FILE" >/dev/null; then
    echo "udev rules already exist, skipping..."
else
    # Echo the rules to the file
    echo "$UDEV_RULES" | tee "$UDEV_FILE" >/dev/null
    # Set correct permissions
    chmod 644 "$UDEV_FILE"
    echo "udev rules added."
fi

# Reload udev rules
udevadm control --reload-rules
udevadm trigger

# Configure display manager
if command -v slim > /dev/null && ! systemctl status gdm | grep -q "disabled"; then
  systemctl disable gdm 2>/dev/null
  systemctl enable slim 2>/dev/null
else
  gdmstatus=$(systemctl status gdm | grep "disabled")
  echo "gdm status: $gdmstatus"
fi

echo '@reboot root echo 85 > \
/sys/class/power_supply/BAT0/charge_control_end_threshold' \
| tee -a /etc/crontab >/dev/null

chsh -s "/bin/ksh" "jbm"

find / -iname '*gnome*' -exec rm -rf {} \; 2>/dev/null
EOF


