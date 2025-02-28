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
# while ($content =~ /"date"(.*?)}/sg) {
#     my $extracted_content = $1;
#     print "$extracted_content\n\n";
# }

# Define a hash map for weather description to Unicode glyphs
my %weather_glyphs = (
    "Sunny"          => "🌞🌞🌞",
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

# Extract and print all content between "date" and "}"
while ($content =~ /"ts":"(.*?)","ds":"(.*?)","icon":\d+,"desc":"(.*?)","temp":(\d+),"templow":(\d+),"cf":\d+,"wind":\d+,"wd":\d+,"hum":\d+,"pc":\d+(?:,"rain":\d+.\d+)?/sg) {
    my ($short_date, $long_date, $desc, $temp, $templow) = ($1, $2, $3, $4, $5);

    # Get the Unicode glyph for the weather description
    my $glyph = $weather_glyphs{$desc} // "";

    # Convert the long date to the required format
    $long_date =~ /^(\w+), (\w+) (\d+)/;
    my $formatted_date = "$1 " . ordinal($3);

    # Print the formatted output
    printf "%-10s%s%-8s Low: %-2d High: %-2d\n", $formatted_date, $glyph, $desc, $templow, $temp;
}

print "\x{1F327}"x5, "\n";
