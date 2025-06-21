#!/usr/bin/perl
use strict;
use warnings;
use File::Temp qw(tempdir);


my $username_file = "$ENV{HOME}/.ssh/grok_username";
open(my $username_fh, '<', $username_file) 
  or die "Cannot open $username_file: $!";
my $username = <$username_fh>;
chomp($username) if defined $username;
close($username_fh);

my $password_file = "$ENV{HOME}/.ssh/grok_password";
open(my $password_fh, '<', $password_file) 
  or die "Cannot open $password_file: $!";
my $password = <$password_fh>;
chomp($password) if defined $password;
close($password_fh);

my $temp_profile = tempdir(CLEANUP => 1);
my $firefox_bin = "/usr/bin/firefox";
my $url = "https://grok.com";
my $cmd = "$firefox_bin --no-remote " .
  "--profile \"$temp_profile\" " .
  "--private-window \"$url\" " .
  ">/dev/null 2>&1 &";
system($cmd) == 0 
  or die "Failed to execute Firefox: $?\n";

sleep 7;
system('xdotool search --onlyvisible --name ' .
  '"Firefox" set_window --name "Grok_Login"');
system('xdotool search --onlyvisible --name ' .
  '"Grok_Login" windowactivate key ctrl+alt+f');
sleep 1.5;

system('xdotool mousemove 1870 180');
system('xdotool click 1');
sleep 4;
system('xdotool mousemove 480 630');
system('xdotool click 1');
sleep 4;
system("xdotool type '$username'");
system('xdotool mousemove 1400 700');
system('xdotool click 1');
sleep 4;
system("xdotool type '$password'");
system('xdotool mousemove 1400 730');
system('xdotool click 1');
system('xdotool mousemove 430 50');
system('xdotool click 1');
