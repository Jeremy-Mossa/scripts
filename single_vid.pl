#!/usr/bin/env perl
use strict;
use warnings;
use 5.40.0;
use utf8;
use autodie qw(:all);
use File::Spec;
use File::Path qw(make_path);

# ----------------------------- CONFIGURATION -----------------------------
my $home   = $ENV{HOME} // die "HOME not set\n";
my $yt_dir = File::Spec->catdir($home, 'videos', 'yt');

# ----------------------------- ARGUMENT CHECK -----------------------------
@ARGV == 1 or die "Usage: $0 <YouTube URL>\n";
my $url = $ARGV[0];

# Basic YouTube URL validation
$url =~ m{^https?://(www\.)?(youtube\.com|youtu\.be|youtube-nocookie\.com)/}
    or die "Not a recognized YouTube URL: $url\n";

# ----------------------------- DIRECTORY SETUP -----------------------------
make_path($yt_dir);  # create if missing, silent if exists

# ----------------------------- INTERNET CHECK -----------------------------
while (1) {
    if (system("/bin/ping -c 2 8.8.8.8 > /dev/null 2>&1") == 0) {
        last;
    }
    sleep 60;
}

# ----------------------------- DOWNLOAD -----------------------------
my @cmd = (
    'yt-dlp',
    '--no-playlist',               # single video only
    '--continue',                  # resume partial downloads
    '--no-warnings',
    '--ignore-errors',
    '--quiet',
    '--progress',                  # shows progress bar in terminal
    '--format', 'bestvideo[height<=1080]+bestaudio/best[height<=1080]',
    '--merge-output-format', 'mp4',  # ensure final file is mp4
    '--output', "$yt_dir/%(title)s [%(id)s].%(ext)s",
    $url
);

if (fork() == 0) {                 # child process
    POSIX::setsid() or die "setsid failed: $!\n";
    open STDOUT, '>', '/dev/null' or die "Can't redirect STDOUT: $!\n";
    open STDERR, '>', '/dev/null' or die "Can't redirect STDERR: $!\n";
    exec @cmd or die "Failed to exec yt-dlp: $!\n";
}
# parent process exits immediately (script returns, download continues in background)
exit 0;
