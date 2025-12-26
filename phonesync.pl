#!/usr/bin/env perl

use strict;
use warnings;
use 5.40.0; # version of erl
use utf8;
use autodie; # to handle errors
use Data::Dumper;


# Exit if no internet access
if (system("/bin/ping -c 2 8.8.8.8 > /dev/null 2>&1") != 0)
{
  print "not online.\n";
  exit;
}

my $local_dir  = '/home/jbm/phone/';
my $android_dir = '/storage/emulated/0/Podcasts/';

my $adbstatus = `adb devices`;
chomp($adbstatus);
print "$adbstatus\n";

# get only the device lines (skip header)
my @lines = split /\n/, $adbstatus;
# has tab = real device line
my @device_lines = grep { /\t/ } @lines;

# keep only authorized devices
my @good_devices = grep { /\tdevice$/ } @device_lines;

if (@good_devices == 0) {
    if (@device_lines == 0) {
        print "\nERROR: No device detected.\n";
        print "Connect your phone and enable USB debugging.\n";
    } else {
        print "\nERROR: Device is unauthorized or offline.\n";
        print "Check your phone screen and accept the RSA key.\n";
    }
    system("/bin/adb kill-server");
    exit 1;
}

system('/home/jbm/scripts/ytdlp.pl') == 0
    or die "ytdlp.pl failed or was interrupted\n";

print "Found " . scalar(@good_devices) . " authorized device(s).\n\n";
# list audio files in 
my $audio_list = `adb shell ls "$android_dir" 2>/dev/null`;

# hash of android podcasts filenames
my %on_android;
foreach my $line (split /\n/, $audio_list) {
    chomp $line;
    next if $line eq '' or $line eq '.' or $line eq '..';
    $on_android{$line} = 1;
}


# rename garbled titles
opendir(my $dh_rename, $local_dir) or die "Can't open $local_dir: $!";
while (my $file = readdir($dh_rename)) {
    next if $file =~ /^\./;  # Skip . and ..
    next unless $file =~ /\.opus$/i;

    my $new = $file;
    $new =~ s/'s/s/g;
    $new =~ s/\[[^]]*\]//g;
    $new =~ s/ \./\./g;
    $new =~ s/  +/ /g;  # collapse whitespaces 
    $new =~ s/ - / /g;
    $new =~ s/- / /g;
    $new =~ s/ -/ /g;
    $new =~ s/, / /g;
    $new =~ s/[()]//g;
    $new =~ s/： /_/g;
    $new =~ s/ ｜ / /g;
    $new =~ s/\.{3}//g;
    $new =~ s/\. \. \. //g;
    $new =~ s/ \. \. \. //g;
    $new =~ s/\.\.\.opus/\.opus/g;
    $new =~ s/\.\.opus/\.opus/g;
    $new =~ s/\.{2}/\./g;
    $new =~ s/ \/\///g;
    $new =~ s/ ⧸⧸//g;
    $new =~ s/!!//g;
    $new =~ s/\s+(?=\.m)/ /g;
    $new =~ s/([^.])mp4$/$1.mp4/i;
    $new =~ s/([^.])opus$/$1.opus/i;

    if ($new ne $file) {
        rename("$local_dir/$file", "$local_dir/$new") or warn "Rename $local_dir/$file to $new failed: $!";
    }
}
closedir($dh_rename);

# list of .opus files in local_dir
my @on_linux;
opendir(my $dh, $local_dir)
  or die "Cannot open directory $local_dir: $!";

while (my $entry = readdir($dh)) {
    # skip if not .opus or not regular file
    next unless $entry =~ /\.opus$/i;
    next unless -f "$local_dir/$entry";

    push @on_linux, $entry;
}

closedir($dh);


# find duplicates and delete them 
# copy remaining from local to android podcast dir
my @to_copy;
for my $file (@on_linux) {
    if (exists $on_android{$file}) {
        unlink "$local_dir$file"   # unlink is perl for rm
            or warn "  Could not delete $file: $!\n";
    } else {
        push @to_copy, $file;
    }
}

# exit if no files exis to copy
if (!@to_copy) {
    print "\nNo files to copy.\n";
    exit 0;
}

# inform for copying and build the copy command
print "\ncopying " . scalar(@to_copy) .
  " new file(s) to Android dir ...\n";
my @push_command = (
    'adb', 'push',
    map("$local_dir$_", @to_copy),   # full paths to local files
    $android_dir
);

system(@push_command) == 0
    or die "\nFailed to copy files with adb push\n";


# delete files in local_dir
for my $file (@to_copy) {
    unlink "$local_dir$file"
        or warn "  Could not delete $local_dir$file: $!\n";
}

# create (or update) the playlist on Android
my $playlist = "$android_dir" . "playlist.m3u";

# go to android, remove old playlist if exists, create new one
system('adb', 'shell',
    "cd \"$android_dir\" && " .
    "rm -f playlist.m3u && " .
    "ls *.opus 2>/dev/null | sort > playlist.m3u"
) == 0
    or die "Failed to create playlist.m3u\n";
