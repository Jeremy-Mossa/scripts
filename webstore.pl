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

# my $resolution = "1920x1200";
# my $output_file = "~/Downloads/webstore_recording.mp4";
# my $ffmpeg_pid = fork();
# if (!$ffmpeg_pid) {
#     # Child process: run ffmpeg
#     exec(
#       "ffmpeg -y " .
#       "-f x11grab " .
#       "-video_size $resolution " .
#       "-framerate 30 " .
#       "-i :99 " .
#       "-c:v libx264 " .
#       "-preset fast " .
#       "-crf 23 " .
#       "-pix_fmt yuv420p " .
#       "$output_file"
#     );
#     exit;  # In case exec fails
# }

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

my $url = "https://store.playcontestofchampions.com";
my $firefox = '/bin/firefox'
  . ' --private-window'
  . " $url"
  . ' >/dev/null 2>&1 &';
system("$firefox");
my $cmd = 'xdotool search --onlyvisible Mozilla >/dev/null 2>&1';
while (system($cmd) != 0) {
  sleep 0.01;
}

system("xdotool key Tab");
system("xdotool key Enter");
sleep 0.5;
sleep 7;
system('xdotool mousemove 635 470');
system('xdotool click 1');
sleep 0.5;
system('xdotool click 1');
sleep 7;
system('xdotool mousemove 644 570');
system('xdotool click 1');
sleep 7;
system("xdotool type '$username'");
system("xdotool key Tab");
sleep 0.25;
system("xdotool type '$password'");
system("xdotool key Enter");
sleep 7;
system("xdotool key Ctrl+Shift+k");

my $command = 'document.querySelectorAll("span[data-testid=\'get-free\']").forEach(el => el.click());';

sleep 1;

foreach my $char (split //, $command) {
    system("xdotool type '$char'");
    system("sleep 0.03");
}
system("xdotool key Return");
sleep 5;
# system("scrot ~/downloads/webstore.png");


# Stop ffmpeg (send SIGINT to finish clean)
# kill 'INT', $ffmpeg_pid;
# waitpid($ffmpeg_pid, 0);

# Kill Xvfb
# system("pkill Xvfb");
