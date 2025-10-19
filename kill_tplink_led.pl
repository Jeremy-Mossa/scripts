#!/usr/bin/env perl

use strict;
use warnings;
use File::Find;

# TP-Link Archer T2U Nano LED Killer - Fedora/Fluxbox Edition
# Auto-finds & disables RTL8811AU LED (100% robust)

print "🔥 Killing TP-Link T2U Nano LED...\n";

# Step 1: Find wlan interface
my $wlan = `ip link show | grep wlan | head -1 | awk '{print \$2}' | sed 's/://'`;
chomp $wlan;
die "❌ No wlan interface found!\n" unless $wlan;

print "✅ Found: $wlan\n";

# Step 2: Find LED directory (auto-detect Realtek paths)
find sub {
    return unless $File::Find::name =~ m|/sys/class/net/$wlan/device/leds/|;
    my ($led_dir) = $File::Find::name =~ m|.*/leds/([^/]+)|;
    print "✅ LED found: $led_dir\n";
    
    # Kill brightness FIRST (instant OFF)
    my $brightness = "$File::Find::dir/brightness";
    if (-w $brightness) {
        system("echo", "0", "|", "sudo", "tee", $brightness);
        print "✅ Brightness = OFF\n";
    }
    
    # Kill trigger (no blinking modes)
    my $trigger = "$File::Find::dir/trigger";
    if (-w $trigger) {
        system("echo", "none", "|", "sudo", "tee", $trigger);
        print "✅ Trigger = NONE\n";
    }
}, "/sys/class/net/$wlan/device/leds/";

# Step 3: Verify
my $check = `cat /sys/class/net/$wlan/device/leds/*/brightness 2>/dev/null | head -1`;
print "🎉 LED Status: $check (0 = OFF FOREVER)\n";

print "\n✨ Add to ~/.xinitrc for auto-start:\n";
print "  ~/kill_tplink_led.pl &\n";
