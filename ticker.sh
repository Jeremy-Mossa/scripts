#!/bin/sh

# List of stock tickers
tickers=(
  "BITO"
  "MAIN"
  "GAIN"
  "HRZN"
  "PFLT"
  "FSK"
  "OXLC"
  "ECC"
)

# Find the length of the longest ticker
max_length=0
for ticker in "${tickers[@]}"; do
  length=${#ticker}
  if [ "$length" -gt "$max_length" ]; then
    max_length="$length"
  fi
done

price_width=7

for ticker in "${tickers[@]}"; do
  gnucash-cli --quotes dump yahoo_json \
    "$ticker" 2>/dev/null > "${ticker}.tkr"

  if [ ! -s "${ticker}.tkr" ]; then
    echo "Failed to fetch quotes for $ticker" >&2
    rm -f "${ticker}.tkr"
    continue
  fi

  price=$(grep 'last =>' "${ticker}.tkr" \
    | cut -d '>' -f2 \
    | sed 's/^[ ]*//; s/,//g')

  rm -f "${ticker}.tkr"

  if [ -z "$price" ]; then
    printf "%-*s: (no price)\n" "$max_length" "$ticker" | lolcat -g FF8800:FFCC00 -b
    continue
  fi

  formatted_price=$(printf "%.2f" "$price")
  price_part="\$$formatted_price"

  printf "%-*s: %*s\n" "$max_length" "$ticker" "$price_width" "$price_part" \
    | lolcat -g FF8800:FFCC00 -b
done
