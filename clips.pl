#!/usr/bin/env perl

use strict;
use warnings;
use 5.40.0; # version of perl
use utf8;
use autodie; # to handle errors
use File::Spec;
use lib "$ENV{HOME}/scripts/lib";
use Renamer qw(clean_filenames);

# ----------------------------- CONFIGURATION -----------------------------
my $home           = $ENV{HOME} // die "HOME not set\n";
my $yt_dir         = File::Spec->catdir($home, 'videos', 'yt');
my $ytdlp_script   = '/home/jbm/scripts/ytdlp.pl';
my $clips_file     = File::Spec->catfile($home, 'Documents', 'clips.txt');

# ----------------------------- INTERNET CHECK -----------------------------
while (1) {
    if (system("/bin/ping -c 2 8.8.8.8 > /dev/null 2>&1") == 0) {
        last;
    }
    sleep 60;
}

# ----------------------------- LOAD CHANNELS -----------------------------

my @channels;

if (-f $clips_file) {
    open my $fh, '<', $clips_file;
    while (my $line = <$fh>) {
        chomp $line;
        next if $line =~ /^\s*$/;   # skip blank
        next if $line =~ /^\s*#/;   # skip comments
        $line =~ s/^\s+|\s+$//g;    # trim
        push @channels, $line if $line =~ /^@/;  # optional safety check
    }
    close $fh;
}
else {
    die "Error: $clips_file not found — cannot proceed.\n";
}

if (not @channels) {
  die "No channels found in $clips_file\n";
}

# ----------------------------- MAIN LOOP -----------------------------
chdir $yt_dir
  or die "failed to chdir into $yt_dir";

clean_filenames();
for my $channel (@channels) {
    system($^X, $ytdlp_script, $channel) == 0
        or die "ytdlp.pl failed for $channel (exit code $?)\n";
    clean_filenames();
}
