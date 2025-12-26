#!/usr/bin/env perl
use strict;
use warnings;
use 5.40.0;
use utf8;
use autodie;
use LWP::UserAgent;

# Orange ANSI color code
my $orange = "\e[38;5;208m";
my $reset  = "\e[0m";

my @tickers = qw(BITO MAIN GAIN HRZN PFLT FSK OXLC ECC);

# Find longest ticker for alignment
my $max_length = 0;
for my $t (@tickers) {
    $max_length = length($t) if length($t) > $max_length;
}

# Fixed width for price column ($xx.xx)
my $price_width = 8;  # room for higher prices

print $orange;  # Start orange color

my $ua = LWP::UserAgent->new;
$ua->agent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36');

for my $ticker (@tickers) {
    my $symbol = lc($ticker) . ".us";
    my $url    = "https://stooq.pl/q/?s=$symbol";

    my $response = $ua->get($url);
    my $page = "";
    if ($response->is_success) {
        $page = $response->content;
    }

    my $price = "";

    # Match Kurs with optional $ and ** (e.g., **$14.2500** or $12.1300)
    if ($page =~ /Kurs\s*\*?\*?\$?(\d+\.\d+)\*?\*?/) {
        $price = $1;
    }
    # Fallback to Poprz. kurs (e.g., 58.9600)
    elsif ($page =~ /Poprz\.\s*kurs\s*(\d+\.\d+)/) {
        $price = $1;
    }

    if ($price eq "") {
        printf "\t%-*s: (no price)\n", $max_length, $ticker;
        next;
    }

    my $formatted = sprintf "%.2f", $price;
    my $price_part = "\$$formatted";

    printf "\t%-*s: %*s\n",
        $max_length, $ticker,
        $price_width, $price_part;
}

print $reset;  # Reset color at end
