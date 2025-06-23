#!/usr/bin/perl
use strict;
use warnings;
use File::Temp qw(tempdir);


# Wait until script has internet access
while (1) {
    if (system("ping -c 1 google.com > /dev/null 2>&1") == 0) {
        last;
    }
    sleep 60;
}

# Check if Xvfb is running, start if not
system("pidof Xvfb || Xvfb :98 -ac -screen 0 1920x1080x24 >/dev/null 2>&1 &");
sleep 5;

# Set DISPLAY environment variable
$ENV{DISPLAY} = ":98";

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
system($cmd) == 0 
  or die "Failed to execute firefox $?\n";

sleep 15;
 
system('xdotool mousemove 1060 150');
system('xdotool click 1');
sleep 1;
system('scrot /home/jbm/pics/pic.png');
system('xdotool mousemove 650 540');
system('xdotool click 1');
sleep 12;
system('scrot /home/jbm/pics/pic.png');
system('xdotool mousemove 650 590');
system('xdotool click 1');
sleep 0.25;
system('scrot /home/jbm/pics/pic.png');
system("xdotool type '$username'");
system('xdotool mousemove 650 690');
system('xdotool click 1');
sleep 0.25;
system('scrot /home/jbm/pics/pic.png');
system("xdotool type '$password'");
system('xdotool mousemove 650 800');
system('xdotool click 1');
system('scrot /home/jbm/pics/pic.png');
sleep 15;
system("xdotool key Ctrl+Shift+k");
system('scrot /home/jbm/pics/pic.png');

my $command = 'document.querySelectorAll("span[data-testid=\'get-free\']").forEach(el => el.click());';
sleep 1;
foreach my $char (split //, $command) {
    system("xdotool type '$char'");
    system("sleep 0.03");
}
system("xdotool key Return");
sleep 1;
system('scrot /home/jbm/pics/webstore.png');

# Kill Xvfb
system("pkill Xvfb");
