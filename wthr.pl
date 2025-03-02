#!/usr/bin/perl

use warnings;
use v5.40;
use utf8;
use autodie;
use open ':std', ':encoding(UTF-8)';

die "Usage: $0 <city>\nExample: $0 Dallas\n" unless @ARGV == 1;
my $city = $ARGV[0];

# use openstreetmap to find and store latitude and longitude
# for a US city provided at the command line
my $geocode_url = "https://nominatim.openstreetmap.org/search?";
my $query       = $geocode_url . "q=$city,US&format=json&limit=1";
my $coords      = `curl -s "$query"`;
my ($lat, $lon);
if ($coords =~ /"lat":"([-.\d]+)".*?"lon":"([-.\d]+)"/s)
{
  $lat = sprintf("%.4f", $1);
  $lon = sprintf("%.4f", $2);
}
else
{
  die "Failed to geocode '$city'. Response: $coords\n";
}

my $points_url   = "https://api.weather.gov/points/$lat,$lon";
my $api_response = `curl -s "$points_url"`;

# $points_url only gives further urls in a json
# we need to find and store the forecast url
if ($api_response =~ /"forecast":"([^"]+)"/)
{
  my $forecast_url = $1;
}
else
{
  die "Failed to extract forecast URL.\n";
}

my $weather = `curl -s "$forecast_url"`;
