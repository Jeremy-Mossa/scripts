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

su <<EOF

PKG="
aalib
acpi
adb 
boxes
bubblewrap
cronie
dillo
dkms
fastboot
fastfetch
feh
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
htop
icecat
inxi
ksh
libcgif
libjpeg
libpng
linux-firmware
lolcat
mullvad-browser
mullvad-vpn
mupdf
mutt
net-tools
perl-Gtk3
perl-HTTP-Tiny
perl-JSON-PP
prename
qmake
redshift
rtorrent
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
xclip
xdotool
xlockmore
xorg
xorg-x11-font-utils
xorg-x11-server-Xorg
xorg-x11-server-Xvfb
xrdb
xsecurelock
xterm
xz-lzma-compat
yt-dlp
"

for package in $PKG; do
  yes | dnf install "$package"
done

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


