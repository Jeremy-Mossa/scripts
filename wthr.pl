#!/usr/bin/perl

use warnings;
use v5.40;
use utf8;
use autodie;
use open ':std', ':encoding(UTF-8)';

# Check input
die "Usage: $0 <city>\nExample: $0 Dallas\n" unless @ARGV == 1;
my $city = $ARGV[0];

# Step 1: Geocode city to lat/lon with Nominatim
my $geocode_url = "https://nominatim.openstreetmap.org/search?q=$city,US&format=json&limit=1";
say "Geocoding URL: $geocode_url";
my $geocode_file = "geocode.json";
system("curl", "-s", $geocode_url, "-o", $geocode_file) == 0 or die "Geocoding failed: $?";

my $geocode_json = do {
    open my $fh, '<', $geocode_file;
    local $/; <$fh>;
};
my ($lat, $lon);
if ($geocode_json =~ /"lat":"([-.\d]+)".*?"lon":"([-.\d]+)"/s) {
    $lat = sprintf("%.4f", $1);
    $lon = sprintf("%.4f", $2);
    say "Coordinates: $lat, $lon";
} else {
    die "Failed to geocode '$city'. Response: $geocode_json\n";
}

# Step 2: Get forecast endpoint from weather.gov
my $points_url = "https://api.weather.gov/points/$lat,$lon";
say "Points URL: $points_url";
my $points_file = "points.json";
system("curl", "-s", $points_url, "-o", $points_file) == 0 or die "Points fetch failed: $?";

my $points_json = do {
    open my $fh, '<', $points_file;
    local $/; <$fh>;
};
my $forecast_url;
if ($points_json =~ /"forecast":"(.*?)"/) {
    $forecast_url = $1;
    say "Forecast URL: $forecast_url";
} else {
    die "Failed to get forecast URL. Response: $points_json\n";
}

# Step 3: Fetch 7-day forecast
my $forecast_file = "forecast.json";
system("curl", "-s", $forecast_url, "-o", $forecast_file) == 0 or die "Forecast fetch failed: $?";

my $forecast_json = do {
    open my $fh, '<', $forecast_file;
    local $/; <$fh>;
};

# Step 4: Parse forecast periods (crudely with regex)
say "\n7-10 Day Forecast for $city:";
my @periods;
while ($forecast_json =~ /"name":"(.*?)".*?"temperature":(\d+).*?"detailedForecast":"(.*?)"/gs) {
    my ($name, $temp, $desc) = ($1, $2, $3);
    push @periods, { name => $name, temperature => $temp, description => $desc };
}

# Print forecast (typically 14 periods, 7 days with day/night)
for my $period (@periods) {
    say "$period->{name}: $period->{temperature}°F - $period->{description}";
}

# Cleanup temporary files
unlink $geocode_file, $points_file, $forecast_file;
