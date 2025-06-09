#!/usr/bin/perl
use strict;
use warnings;
use File::Temp qw(tempdir);

# Check if Xvfb is running, start if not
system("pidof Xvfb || Xvfb :99 -ac -screen 0 1920x1080x24 &");
sleep 5;  # Increased sleep for Fedora stability

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
my $browser_bin = "/bin/icecat";
my $url = "https://store.playcontestofchampions.com";
my $cmd = "$browser_bin --no-remote " .
  "--profile \"$temp_profile\" " .
  "--private-window \"$url\" " .
  ">/dev/null 2>&1 &";
system($cmd) == 0 
  or die "Failed to execute icecat $?\n";



sleep 10;
 
system('xdotool mousemove 777 127');
system('xdotool click 1');
sleep 1;
system('xdotool mousemove 500 540');
system('xdotool click 1');
sleep 8;
system('xdotool mousemove 500 580');
system('xdotool click 1');
sleep 0.25;
system("xdotool type '$username'");
system('xdotool mousemove 500 660');
system('xdotool click 1');
sleep 0.25;
system("xdotool type '$password'");
system('xdotool mousemove 500 730');
system('xdotool click 1');
system('scrot /home/jbm/icecat.png');
# sleep 10;
# system("xdotool key Ctrl+Shift+k");
# 
# my $command = 'document.querySelectorAll("span[data-testid=\'get-free\']").forEach(el => el.click());';
# sleep 1;
# foreach my $char (split //, $command) {
#     system("xdotool type '$char'");
#     system("sleep 0.03");
# }
# system("xdotool key Return");
# sleep 1;
#
# Kill Xvfb
system("pkill Xvfb");
