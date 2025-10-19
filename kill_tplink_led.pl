#!/usr/bin/perl
use strict;
use warnings;


my $wlan = "wlp2s0f3u4";

system("sudo", "sh", "-c", "echo 0 > /sys/class/ieee80211/phy0/device/leds/*/brightness 2>/dev/null");
system("sudo", "sh", "-c", "echo none > /sys/class/ieee80211/phy0/device/leds/*/trigger 2>/dev/null");
system("sudo", "sh", "-c", "echo 0 > /sys/bus/usb/devices/*/leds/*/brightness 2>/dev/null");

system("sudo", "sh", "-c", "
cat > /etc/udev/rules.d/99-tplink-led-off.rules << 'EOF'
ACTION==\"add\", SUBSYSTEM==\"leds\", ATTR{brightness}=\"0\"
ACTION==\"add\", SUBSYSTEM==\"leds\", ATTR{trigger}=\"none\"
EOF
udevadm control --reload-rules
udevadm trigger
");

my $before = `cat /sys/class/ieee80211/phy0/device/leds/*/brightness 2>/dev/null | head -1 || echo 1`;
my $after = `ls /sys/class/ieee80211/phy0/device/leds/*/brightness 2>/dev/null && echo 0 || echo 1`;
print "📊 BEFORE: $before → AFTER: $after (0 = DEAD)\n";

print "\n✨ REBOOT NOW\n";
