#!/usr/bin/env perl
use strict;
use warnings;
use 5.40.0;
use utf8;
use autodie;
use HTTP::Tiny;

# Orange ANSI color code
my $orange = "\e[38;5;208m";
my $reset  = "\e[0m";

my @tickers = (
    "BITO",
    "MAIN",
    "GAIN",
    "HRZN",
    "PFLT",
    "OXLC",
    "FSK",
    "ECC"
);

my $cache_file = "/home/jbm/Documents/ticker_cache";

# Load cache if exists
my %cache;
if (-f $cache_file) {
    open my $fh, '<', $cache_file;
    while (my $line = <$fh>) {
        chomp $line;
        my ($tick, $pr) = split /:/, $line;
        $cache{$tick} = $pr if $tick && $pr;
    }
    close $fh;
}

# Find longest ticker for alignment
my $max_length = 0;
for my $t (@tickers) {
    $max_length = length($t) if length($t) > $max_length;
}

# Fixed width for price column ($xx.xx)
my $price_width = 8;  # room for higher prices

my $update_only = 0;
if (@ARGV && $ARGV[0] eq '--update-only') {
    $update_only = 1;
}

my $http = HTTP::Tiny->new;

sub update_cache {
    my %new_prices;
    for my $ticker (@tickers) {
        my $symbol = lc($ticker) . ".us";
        my $url = "https://stooq.pl/q/?s=$symbol";

        my $response = $http->get($url);

        my $price = "";

        if ($response->{success}) {
            my $page = $response->{content};
            if ($page =~ /id=aq_\Q$symbol\E_c4>(\d+\.\d+)/) {
                $price = $1;
            }
        }

        if ($price ne "") {
            $new_prices{$ticker} = sprintf "%.2f", $price;
        }
    }

    # Write updated cache
    open my $fh, '>', $cache_file;
    for my $tick (@tickers) {
        my $pr = $new_prices{$tick} // $cache{$tick} // '(no price)';
        print $fh "$tick:$pr\n";
    }
    close $fh;
}

if ($update_only) {
    update_cache();
    exit;
}

# Print from cache
print $orange;  # Start orange color

for my $ticker (@tickers) {
    my $price = $cache{$ticker} // "";
    if ($price eq "") {
        printf "\t%-*s: (no price)\n", $max_length, $ticker;
        next;
    }

    my $price_part = "\$$price";

    printf "\t%-*s: %*s\n",
        $max_length, $ticker,
        $price_width, $price_part;
}

print $reset;  # Reset color at end

# Update in background
if (my $pid = fork) {
    # Parent
} elsif (defined $pid) {
    # Child
    update_cache();
    exit;
} else {
    warn "Fork failed: $!\n";
}
