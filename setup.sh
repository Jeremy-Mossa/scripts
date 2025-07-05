#!/bin/sh

DIRS="
books
C
C++
documents
freebsd
perl
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

# Define a udev rule to detect android devices
UDEV_RULE='SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ACTION=="add", RUN+="/usr/local/bin/android-detect.sh"'
UDEV_FILE="/etc/udev/rules.d/99-android-detect.rules"

# Check if the rule already exists in the file
if [ -f "$UDEV_FILE" ] && grep -Fx "$UDEV_RULE" "$UDEV_FILE" >/dev/null; then
    echo "udev rule already exists, skipping..."
else
    # Echo the rule to the file
    echo "$UDEV_RULE" | tee "$UDEV_FILE" >/dev/null
    # Set correct permissions
    chmod 644 "$UDEV_FILE"
    echo "udev rule added."
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

# find / -iname '*gnome*' -exec rm -rf {} \; 2>/dev/null

chsh -s "/bin/ksh" "jbm"
EOF


