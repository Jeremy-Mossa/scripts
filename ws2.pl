#!/usr/bin/perl
use strict;
use warnings;
use File::Temp qw(tempdir);


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
my $firefox_bin = "/usr/bin/firefox";
my $url = "https://store.playcontestofchampions.com";
my $cmd = "$firefox_bin --no-remote " .
  "--profile \"$temp_profile\" " .
  "--private-window \"$url\" " .
  ">/dev/null 2>&1 &";
system($cmd) == 0 
  or die "Failed to execute Firefox: $?\n";

sleep 6;
system('xdotool search --onlyvisible --name ' .
  '"Firefox" set_window --name "mcoc"');
system('xdotool search --onlyvisible --name ' .
  '"mcoc" windowactivate key ctrl+alt+f');
sleep 3;

system('xdotool mousemove 1700 170');
system('xdotool click 1');
sleep 1;
system('xdotool mousemove 970 580');
system('xdotool click 1');
sleep 6;
system('xdotool mousemove 950 630');
system('xdotool click 1');
sleep 0.25;
system("xdotool type '$username'");
system('xdotool mousemove 950 705');
system('xdotool click 1');
sleep 0.25;
system("xdotool type '$password'");
system('xdotool mousemove 960 820');
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
