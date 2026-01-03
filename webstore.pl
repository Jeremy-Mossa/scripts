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

system('/bin/icecat >/dev/null 2>&1 &');
my $cmd = 'xdotool search --onlyvisible IceCat >/dev/null 2>&1';
while (system($cmd) != 0) {
  sleep 0.001;
}

my $url = "https://store.playcontestofchampions.com";
system("xdotool type --delay 0 $url");
system('xdotool key Enter');
system("scrot ~/downloads/webstore.png");

sleep 7;

# Find and position the browser window
my $window_id = `xdotool search --onlyvisible --name "IceCat"`;
chomp($window_id);
if ($window_id) {
    system("xdotool windowmove $window_id 0 0");
    system("xdotool windowsize $window_id 1900 1060");
} else {
    warn "Could not find browser window $window_id.\n";
}

sleep 3;
system("scrot ~/downloads/webstore.png");

system('xdotool mousemove 1680 143');
system('xdotool click 1');
sleep 0.5;
system('xdotool click 1');
sleep 10;
system("scrot ~/downloads/webstore.png");
system('xdotool mousemove 933 611');
system('xdotool click 1');
sleep 0.5;
system('xdotool click 1');
sleep 12;
system("scrot ~/downloads/webstore.png");
system('xdotool mousemove 940 595');
system('xdotool click 1');
sleep 10;
system("xdotool type '$username'");
system("scrot ~/downloads/webstore.png");
system('xdotool mousemove 940 667');
system('xdotool click 1');
sleep 0.25;
system("xdotool type '$password'");
system("scrot ~/downloads/webstore.png");
system('xdotool mousemove 940 787');
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
sleep 5;
system("scrot ~/downloads/webstore.png");

# system("scrot /downloads/webstore.png");

# Stop ffmpeg (send SIGINT to finish clean)
# kill 'INT', $ffmpeg_pid;
# waitpid($ffmpeg_pid, 0);

# Kill Xvfb
system("pkill Xvfb");
