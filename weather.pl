#!/usr/bin/perl

use warnings;
use v5.40;
use utf8;
use autodie;
use open ':std', ':encoding(UTF-8)';

# ANSI escape codes for colors
my $green = "\033[32m";
my $blue  = "\033[34m";
my $red   = "\033[31m";
my $reset = "\033[0m";

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
# while ($content =~ /"date"(.*?)}/sg) {
#     my $extracted_content = $1;
#     print "$extracted_content\n\n";
# }

# Define a hash map for weather description to Unicode glyphs
my %weather_glyphs = (
    "Sunny"          => "\x{2600}",
    "Partly cloudy"  => "\x{26C5}",
    "Cloudy"         => "\x{2601}",
    "Light rain"     => "\x{1F327}",
);

# Helper function to convert date to ordinal
sub ordinal {
    my $n = shift;
    return $n . 'th' if $n =~ /1[0-9]$/;
    return $n . 'st' if $n =~ /1$/;
    return $n . 'nd' if $n =~ /2$/;
    return $n . 'rd' if $n =~ /3$/;
    return $n . 'th';
}

# get the nicely formatted city name
my $location = ($content =~ /banner__title>(.*?) 14/) ? $1 : undef;

print "-"x54, "\n";
print "14-day forecast for $location\n\n";

# Extract and print all content between "date" and "}"
while ($content =~ /"ts":"(.*?)","ds":"(.*?)","icon":\d+,"desc":"(.*?)","temp":(\d+),"templow":(\d+),"cf":\d+,"wind":\d+,"wd":\d+,"hum":\d+,"pc":\d+(?:,"rain":\d+.\d+)?/sg) {
    my ($short_date, $long_date, $desc, $temp, $templow) = ($1, $2, $3, $4, $5);

    # Convert the long date to the required format
    $long_date =~ /^(\w+), (\w+) (\d+)/;
    my $formatted_date = "$1 " . ordinal($3);

    # Print the formatted output with colors and formatting
    printf "\t${green}%-10s%26s${reset}\n", $formatted_date, $desc;
    printf "\t${blue}Low: %-2d${reset}\t${red}High: %-2d${reset}\n\n", $templow, $temp;
}
print "-"x54, "\n";
