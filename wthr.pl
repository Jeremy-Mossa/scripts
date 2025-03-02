#!/usr/bin/perl

use warnings;
use v5.40;
use utf8;
use autodie;
use open ':std', ':encoding(UTF-8)';

die "Usage: $0 <city>\nExample: $0 Dallas\n" unless @ARGV == 1;
my $city = $ARGV[0];

# Step 1: Geocode the city to get latitude and longitude using Nominatim
my $geocode_url = "https://nominatim.openstreetmap.org/search?q=$city,US&format=json&limit=1";
my $geocode_json = `curl -s "$geocode_url"`;

# Basic JSON parsing without modules (assumes simple structure)
my ($lat, $lon);
if ($geocode_json =~ /"lat":"([-.\d]+)".*?"lon":"([-.\d]+)"/s) {
    $lat = sprintf("%.4f",$1);
    $lon = sprintf("%.4f",$2);
} else {
    die "Failed to geocode '$city'. Response: $geocode_json\n";
}

print "Coordinates for $city: $lat, $lon\n";

# Step 2: Query weather.gov points endpoint
my $points_url = "https://api.weather.gov/points/$lat,$lon";
my $points_json = `curl -s "$points_url"`;

# Extract forecast URL from points response
my $forecast_url;
if ($points_json =~ /"forecastHourly":"(.*?)"/) {
    $forecast_url = $1;
} else {
    die "Failed to get forecast URL. Response: $points_json\n";
}

# Step 3: Fetch the hourly forecast
my $forecast_json = `curl -s "$forecast_url"`;

# Extract the current temperature (first period)
my $temperature;
if ($forecast_json =~ /"temperature":(\d+)/) {
    $temperature = $1;
} else {
    die "Failed to parse temperature. Response: $forecast_json\n";
}

print "Current temperature in $city: $temperature°F\n";
