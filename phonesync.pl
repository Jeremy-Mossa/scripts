#!/usr/bin/env perl

use strict;
use warnings;
use 5.40.0; # version of perl
use utf8;
use autodie; # to handle errors
use Data::Dumper;

# make Data::Dumper pretty-print
$Data::Dumper::Terse = 1; # just dump data contents
$Data::Dumper::Indent = 0; # single-line output

my $local_dir  = '/home/user/phone/';
my $android_dir = '/storage/emulated/0/Podcasts/';

my $adbstatus = `adb devices`;
chomp($adbstatus);
print "$adbstatus\n";

# list audio files in 
my $audio_list = `adb shell ls "$android_dir" 2>/dev/null`;

# hash of remote filenames
my %on_android;
foreach my $line (split /\n/, $audio_list) {
    chomp $line;
    next if $line eq '' or $line eq '.' or $line eq '..';
    $on_android{$line} = 1;
}

# list of .opus files in local_dir
my @on_linux;
opendir(my $dh, $local_dir) 
  or die "Cannot open directory $local_dir: $!";

while (my $entry = readdir($dh)) {
    next unless $entry =~ /\.opus$/i;    # skip if not ending in .opus (case-insensitive)
    next unless -f "$local_dir$entry";   # skip if not a regular file

    push @on_linux, $entry;
}

closedir($dh);

# Optional: sort for nicer, predictable output
@on_linux = sort @on_linux;

print "\nLocal .opus files (" . scalar(@on_linux) . "):\n";
for my $file (@on_linux) {
    print "  $file\n";
}

print "\nChecking for duplicates already on Android...\n";

my @to_copy;

for my $file (@on_linux) {
    if (exists $on_android{$file}) {
        print "  Duplicate found → deleting local: $file\n";
        unlink "$local_dir$file"   # delete the local copy
            or warn "  Could not delete $file: $!\n";
    } else {
        print "  Will copy: $file\n";
        push @to_copy, $file;
    }
}

# If nothing to copy, we're done
if (!@to_copy) {
    print "\nNo new files to copy. All done!\n";
    exit 0;
}

# Copy all remaining files in one command (fast and simple)
print "\nCopying " . scalar(@to_copy) . " new file(s) to Android...\n";

my @push_command = (
    'adb', 'push',
    map("$local_dir$_", @to_copy),   # full paths to local files
    $android_dir
);

system(@push_command) == 0
    or die "\nFailed to copy files with adb push\n";

print "Copy complete!\n";

# Now delete all the files we just successfully copied
print "\nCleaning up local directory...\n";
for my $file (@to_copy) {
    unlink "$local_dir$file"
        or warn "  Could not delete $local_dir$file: $!\n";
    else {
        print "  Deleted local: $file\n";
    }
}

print "\nAll done! Local directory cleaned.\n";
