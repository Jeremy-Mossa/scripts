#!/usr/bin/perl

use warnings;
use v5.40;
use utf8;
use autodie;

die "Usage: $0 <city>\nExample: $0 Dallas\n" unless @ARGV == 1;
my $city = $ARGV[0];

# use openstreetmap to find and store latitude and
# longitude for a US city provided at cli
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

system('rm forecast.txt');

my %months = (
              1  => "JAN",
              2  => "FEB",
              3  => "MAR",
              4  => "APR",
              5  => "MAY",
              6  => "JUN",
              7  => "JUL",
              8  => "AUG",
              9  => "SEP",
              10 => "OCT",
              11 => "NOV",
              12 => "DEC",
             );

# Store periods by day
my %days_data;

while ($forecast =~
  /"name": "([^"]+)".*?"startTime": "(\d{4})-(\d{2})-(\d{2})T[^"]+".*?"isDaytime": (true|false).*?"temperature": (\d+).*?"probabilityOfPrecipitation".*?"value": (\d+|null).*?"shortForecast": "([^"]+)"/gs
  )
{
  my ($name, $year, $month, $day, $is_daytime, $temp, $precip, $short_forecast)
    = ($1, $2, $3, $4, $5, $6, $7, $8);

  my $date_key = "$year-$month-$day";
  my ($day_name) = $name =~ /^(\w+)/;

  $days_data{$date_key} ||= {};
  if ($is_daytime eq "true")
  {
    $days_data{$date_key}{day_name}       = $day_name;
    $days_data{$date_key}{day_temp}       = $temp;
    $days_data{$date_key}{short_forecast} = $short_forecast;
    $days_data{$date_key}{month}          = 0 + $month;
    $days_data{$date_key}{day}            = 0 + $day;
  }
  else
  {
    $days_data{$date_key}{night_temp} = $temp;
  }
  $precip = undef if $precip eq "null";
  $days_data{$date_key}{precip} = $precip
    if defined $precip
    && (!defined $days_data{$date_key}{precip}
        || $precip > $days_data{$date_key}{precip});
}

$city =~ s/-([a-z])/ \u$1/g;
$city = ucfirst $city;
print "\n";
print "\t", "-" x 32, "\n";
say "\tWeather for $city";
print "\t", "-" x 32, "\n";

# Process and print each day
for my $date_key (sort keys %days_data)
{
  my $data = $days_data{$date_key};
  next unless defined $data->{day_temp} && defined $data->{night_temp};

  my $day   = $data->{day};
  my $month = $data->{month};
  my $suffix =
    $day =~ /1$/ ? "st" : $day =~ /2$/ ? "nd" : $day =~ /3$/ ? "rd" : "th";
  my $formatted_date = "$data->{day_name}, $months{$month} $day$suffix";

  say "\t$formatted_date";
  # say "\tLow: $data->{night_temp}°   Hi: $data->{day_temp}°";
  say "\tLow: $data->{night_temp}   Hi: $data->{day_temp}";
  say "\t$data->{short_forecast}";
  say "\tChance: ", defined $data->{precip} ? "$data->{precip}%" : "0%";
  print "\n";
}
print "\t", "-" x 32, "\n\n";
