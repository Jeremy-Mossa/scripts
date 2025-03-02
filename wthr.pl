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

# $points_url only gives further urls in a JSON
# we need to find and store the forecast url
my $forecast_url;
if ($api_response =~ /"forecast": "([^"]+)"/)
{
  $forecast_url = $1;
}
else
{
  die "Failed to extract forecast URL.\n";
}

# save the forecast JSON response
my $forecast = `curl -s "$forecast_url"`;

my @labels = qw(
  name
  startTime
  temperature
  temperatureUnit
  value
  shortForecast
);

foreach my $label (@labels)
{
  say $label;
}


# "periods": [
#            {
#                "number": 1,
#                "name": "Overnight",
#                "startTime": "2025-03-02T00:00:00-06:00",
#                "endTime": "2025-03-02T06:00:00-06:00",
#                "isDaytime": false,
#                "temperature": 56,
#                "temperatureUnit": "F",
#                "temperatureTrend": "",
#                "probabilityOfPrecipitation": {
#                    "unitCode": "wmoUnit:percent",
#                    "value": null
#                },
#                "windSpeed": "5 mph",
#                "windDirection": "ESE",
#                "icon": "https://api.weather.gov/icons/land/night/few?size=medium",
#                "shortForecast": "Mostly Clear",
#                "detailedForecast": "Mostly clear, with a low around 56. East southeast wind around 5 mph."
#            },
#
