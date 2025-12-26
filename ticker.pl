#!/usr/bin/env perl
use strict;
use warnings;
use 5.40.0;
use utf8;
use autodie;
use Mojolicious::Lite;

# Orange ANSI color code
my $orange = "\e[38;5;208m";
my $reset  = "\e[0m";

my @tickers = (
    "DIVO",
    "BITO",
    "SVOL",
    "JEPQ",
    "MAIN",
    "GAIN",
    "HRZN",
    "PFLT",
    "OXLC",
    "DX"
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

my $ua = Mojo::UserAgent->new;
$ua->inactivity_timeout(10);
$ua->max_connections(30);
$ua->transactor->name('Mozilla/5.0');

sub update_cache {
    my %new_prices;

    my @promises;

    for my $ticker (@tickers) {
        my $symbol = lc($ticker) . ".us";
        my $url    = "https://stooq.pl/q/?s=$symbol";

        my $p = $ua->get_p($url)->then(sub {
            my ($tx) = @_;
            my $price = "";

            if ($tx->success) {
                my $page = $tx->res->body;
                if ($page =~ /id=aq_\Q$symbol\E_c4>(\d+\.\d+)/) {
                    $price = $1;
                }
            }

            if ($price ne "") {
                $new_prices{$ticker} = sprintf "%.2f", $price;
            }
        })->catch(sub {
            warn "Failed to fetch $ticker: @_\n" if 0;  # set to 1 for debug
        });

        push @promises, $p;
    }

    # block until all requests are done
    Mojo::Promise->all(@promises)->wait;

    # write updated cache
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

# print from cache
print $orange;  # start orange color

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

print $reset;  # reset color at end

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
