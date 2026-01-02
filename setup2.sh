#!/bin/sh


if [ ! -f /etc/yum.repos.d/rpmfusion-free-release.repo ]; then
    dnf install -y \
        https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm || {
        echo "Error: Failed to install RPM Fusion repo" >&2
        exit 1
    }
fi

PKG="
aalib
acpi
adb 
boxes
btop
bubblewrap
chromium
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
fontawesome-fonts
fzf
gcc
giflib
gimp
git
gnome-boxes
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
macchanger
meson
midori
mullvad-browser
mullvad-vpn
mupdf
mutt
net-tools
ninja-build
perl-doc
perl-Gtk3
perl-Inline-C
perl-PDL
perl-WWW-Curl
perl-HTTP-Tiny
perl-JSON-PP
perl-Mojo-IOLoop-ReadWriteProcess
perl-Mojolicious
pkgconf-pkg-config
prename
python3-numpy
python3-opencv
qalculate-qt
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
urw-fonts
vim
vimb
vlc
xclip
xdotool
xev
xlockmore
xorg
xorg-x11-font-utils
xorg-x11-server-Xorg
xorg-x11-server-Xvfb
xorg-x11-server-Xwayland
xrdb
xsecurelock
xterm
xwininfo
xz-devel
xz-lzma-compat
yt-dlp
qemu-kvm
libvirt
virt-install
virt-manager
bridge-utils
java-17-openjdk
zlib.i686
ncurses-libs.i686
bzip2-libs.i686
libguestfs-tools-c
parallel
tlp
tlp-rdw
calibre
mpv
dbus-x11
clipit
thunderbird
libavcodec-freeworld
polybar
rofi
"

dnf install -y \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

for package in $PKG; do
  if which "$package" >/dev/null 2>&1 \
    || rpm -q "$package" >/dev/null 2>&1; then
    echo "$package already installed"
  else
    yes | dnf install "$package"
  fi
done

# ensure .mkv are playable
dnf swap -y ffmpeg-free ffmpeg --allowerasing

# For some reason dnf wouldn't do it
yum install VirtualBox-7.1

# Get android-x86 and gapps to emulate devices in gnome-boxes
wget -O ~/downloads/android-x86_64-9.0-r2.iso \
  https://sourceforge.net/projects/android-x86/files/Release%209.0/android-x86_64-9.0-r2.iso/download
wget -O ~/downloads/open_gapps-x86_64-9.0-pico-20220503.zip \
  https://sourceforge.net/projects/opengapps/files/x86_64/20220503/open_gapps-x86_64-9.0-pico-20220503.zip/download
mv ~/downloads/android-x86* androidx86.iso
mv ~/downloads/open_gapps-x86* open_gappsx86.zip

# Install Open GApps via ADB (after enabling USB debugging)
adb connect localhost:5555
adb push ~/downloads/open_gappsx86.zip /sdcard/
adb shell recovery --install /sdcard/open_gappsx86.zip

systemctl enable libvirtd
systemctl start libvirtd

echo "Configuring KVM permissions for user jbm..."
usermod -aG render jbm
usermod -aG kvm jbm
usermod -aG libvirt jbm
usermod -aG vboxusers jbm
modprobe kvm_intel
echo "kvm_intel" >> /etc/modules-load.d/kvm.conf
echo "Verifying KVM setup..."
if [ -c /dev/kvm ]; then
    echo "KVM device found, setup successful."
else
    echo "Error: KVM device not found!" >&2
    exit 1
fi

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


### Begin SLiM setup
# Define the SLiM configuration file
SLIM_CONF="/etc/slim.conf"

# Check if current_theme is already set to original
if grep -q "^current_theme.*original" "$SLIM_CONF" >/dev/null 2>&1; then
    exit 0
fi

# Replace or append current_theme original
if grep -q "^current_theme" "$SLIM_CONF" >/dev/null 2>&1; then
    sed -i 's/^current_theme.*/current_theme original/' "$SLIM_CONF" >/dev/null 2>&1
else
    echo "current_theme original" >> "$SLIM_CONF" 2>/dev/null
fi
### End SLiM setup


# Configure display manager
if command -v slim > /dev/null && ! systemctl status gdm | grep -q "disabled"; then
  systemctl disable gdm 2>/dev/null
  systemctl enable slim 2>/dev/null
else
  gdmstatus=$(systemctl status gdm | grep "disabled")
  echo "gdm status: $gdmstatus"
fi

# Disable X11 screensaver and DPMS
echo -e "Section \"ServerFlags\"\n\
    Option \"BlankTime\" \"0\"\n\
    Option \"StandbyTime\" \"0\"\n\
    Option \"SuspendTime\" \"0\"\n\
    Option \"OffTime\" \"0\"\n\
EndSection" > /etc/X11/xorg.conf.d/10-monitor.conf
chmod 644 /etc/X11/xorg.conf.d/10-monitor.conf

# Check if systemd-logind is installed
if [ -f /etc/systemd/logind.conf ]; then
    # Disable systemd suspend on idle
    sed -i 's/#IdleAction=.*$/IdleAction=ignore/' /etc/systemd/logind.conf
    sed -i 's/#HandleSuspendKey=.*$/HandleSuspendKey=ignore/' /etc/systemd/logind.conf
    systemctl restart systemd-logind
else
    # Disable suspend via kernel parameter
    echo "kernel.suspend=0" > /etc/sysctl.d/99-disable-suspend.conf
    # Ensure acpid (if present) ignores power events
    if command -v acpid >/dev/null; then
        echo "button/power.*) :;" > /etc/acpi/events/power
        systemctl restart acpid
    fi
fi

# disable fluxbox system tray and remove from toolbar list
INIT_FILE="${HOME}/.fluxbox/init"

# Replace existing toolbar.visible line with false
if grep -q '^[[:space:]]*session\.screen0\.toolbar\.visible:' "${INIT_FILE}"; then
    sed -i 's/^[[:space:]]*session\.screen0\.toolbar\.visible:.*/session.screen0.toolbar.visible: false/' "${INIT_FILE}"
fi

# If the line doesn't exist, append it
if ! grep -q '^[[:space:]]*session\.screen0\.toolbar\.visible:' "${INIT_FILE}"; then
    printf '%s\n' 'session.screen0.toolbar.visible: false' >> "${INIT_FILE}"
fi
sed -i '/^[[:space:]]*session\.screen0\.toolbar\.tools:/ {
    s/[[:space:]]*,[[:space:]]*systemtray[[:space:]]*\([,:]\|$\)/\1/g
    s/^[[:space:]]*systemtray[[:space:]]*,//
}' "${INIT_FILE}"
# finish disable system tray

echo '@reboot root echo 85 > \
/sys/class/power_supply/BAT0/charge_control_end_threshold' \
| tee -a /etc/crontab >/dev/null

chsh -s "/bin/ksh" "jbm"

dnf remove -y gnome-shell gnome-* gdm \
  || echo "some gnome pkgs not found"

if rpm -q gnome-shell >/dev/null; then
  rpm -e --nodeps gnome-shell
fi
