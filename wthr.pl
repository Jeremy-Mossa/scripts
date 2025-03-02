#!/usr/bin/perl

use warnings;
use v5.40;
use utf8;
use autodie;
use open ':std', ':encoding(UTF-8)';

die "Usage: $0 <city>\nExample: $0 Dallas\n" unless @ARGV == 1;
my $city = $ARGV[0];

# get latitude and longitude coords
my $url = "https://nominatim.openstreetmap.org/search?";
my $geocode_query = $url . "q=$city,US&format=json&limit=1";
my $geocode_json = system("curl -s "$geocode_query"");
my ($lat, $lon);
if ($geocode_json =~ /"lat":"([-.\d]+)".*?"lon":"([-.\d]+)"/s) {
    $lat = sprintf("%.4f",$1);
    $lon = sprintf("%.4f",$2);
} else {
    die "Failed to geocode '$city'.\n";
}

# Query weather.gov with coords
my $wthr_url = "https://forecast.weather.gov/";
my $query_url = $wthr_url . "MapClick.php?lat=$lat&lon=$lon";
system("curl -s -o forecast.html "$weather_url$locale"");

