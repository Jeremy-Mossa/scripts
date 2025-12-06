#!/usr/bin/env perl

use 5.40.0;
use strict;
use warnings;
use autodie;
use File::Temp qw(tempdir);


# Wait until script has internet access
while (1) {
    if (system("/bin/ping -c 2 8.8.8.8 > /dev/null 2>&1") == 0) {
        last;
    }
    sleep 60;
}

print "Connected\n";

# Check if Xvfb is running, start if not
system("pidof Xvfb || Xvfb :99 -ac -screen 0 1920x1200x24 >/dev/null 2>&1 &");
sleep 5;

# Set DISPLAY environment variable
$ENV{DISPLAY} = ":99";

my $username_file = "$ENV{HOME}/.ssh/mcoc_username";
open(my $username_fh, '<', $username_file) 
  or die "Cannot open $username_file: $!";
my $username = <$username_fh>;
chomp($username) if defined $username;
close($username_fh);

my $password_file = "$ENV{HOME}/.ssh/mcoc_password";
open(my $password_fh, '<', $password_file) 
  or die "Cannot open $password_file: $!";
my $password = <$password_fh>;
chomp($password) if defined $password;
close($password_fh);

my $temp_profile = tempdir(CLEANUP => 1);
my $browser_bin = "/bin/firefox";
my $url = "https://store.playcontestofchampions.com";
my $cmd = "$browser_bin --no-remote " .
          "--profile \"$temp_profile\" " .
          "--private-window \"$url\" " .
          ">/dev/null 2>&1 &";
system($cmd) == 0 or die "Failed to execute firefox: $?";

sleep 7;

# Find and position the Firefox window
my $window_id = `xdotool search --onlyvisible --name "Mozilla"`;
chomp($window_id);
if ($window_id) {
    system("xdotool windowmove $window_id 0 0");
    system("xdotool windowsize $window_id 1900 1060");
} else {
    warn "Could not find Firefox window $window_id. Screenshot may fail.\n";
}

sleep 3;

system('xdotool mousemove 1690 105');
system('xdotool click 1');
sleep 0.5;
system('xdotool click 1');
sleep 10;
system('xdotool mousemove 940 582');
system('xdotool click 1');
sleep 0.5;
system('xdotool click 1');
sleep 12;
system('xdotool mousemove 940 555');
system('xdotool click 1');
sleep 10;
system("xdotool type '$username'");
system('xdotool mousemove 940 627');
system('xdotool click 1');
sleep 0.25;
system("xdotool type '$password'");
system('xdotool mousemove 940 747');
system('xdotool click 1');
sleep 10;
system("xdotool key Ctrl+Shift+k");

my $command = 'document.querySelectorAll("span[data-testid=\'get-free\']").forEach(el => el.click());';
sleep 1;
foreach my $char (split //, $command) {
    system("xdotool type '$char'");
    system("sleep 0.03");
}
system("xdotool key Return");
sleep 1;

# system("scrot webstore.png");

# Kill Xvfb
system("pkill Xvfb");
