#!/usr/bin/perl

use warnings;
use v5.40;
use utf8;
use autodie;


# Check if the correct number of arguments are provided
if (@ARGV != 2) {
    die "Usage: perl script.pl <city> <country>\n";
}

my $city = $ARGV[0];
my $country = $ARGV[1];
my $url = "https://www.timeanddate.com/weather/$country/$city/ext";
my $file = 'forecast.html';

my $curl_command = "curl -o $file $url";
my $result = system($curl_command);

if ($result == 0) {
    print "Website content saved to $file\n";
} else {
    print "Failed to retrieve content from $url\n";
}

# Open the file for reading
open(my $fh, '<', $file) or die "Could not open file '$file' $!";

# Read the file content
my $content = do { local $/; <$fh> };

# Close the file
close $fh;

# Extract and print all content between "date" and "}"
while ($content =~ /"date"(.*?)}/sg) {
    my $extracted_content = $1;
    print "$extracted_content\n";
}
