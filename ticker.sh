#!/bin/sh

# List of stock tickers
tickers=(
  # Monthly Payers (REITs, Financials, Utilities)
  "BITO"   # Bitcoin futures
  "MAIN"   # Best BDC
  "GAIN"   # Gladstone Investment (BDC, buyouts)
  "HRZN"   # Horizon Technology Finance (venture loans)
  "PFLT"   # PennantPark Floating Rate Capital (BDC)
  "FSK"    # FS KKR Capital (BDC, private credit)
  "OXLC"   # Oxford Lane Capital (CLO investments)
  "ECC"    # Eagle Point Credit (CLO equity)
)
for ticker in "${tickers[@]}"; do
  # Fetch quotes and save to temporary file
  gnucash-cli --quotes dump yahoo_json \
    "$ticker" 2>/dev/null > "${ticker}.tkr"

  # Check if file is empty or quotes failed
  if [ ! -s "${ticker}.tkr" ]; then
    echo "Failed to fetch quotes for $ticker" >&2
    rm "${ticker}.tkr"
    continue
  fi

  # Extract price
  price=$(grep last "${ticker}.tkr" \
    | cut -d':' -f2 \
    | cut -d'<' -f1 \
    | sed 's/^[ ]*//')

  # Check if price is empty
  if [ -z "$price" ]; then
    echo "No price found for $ticker" >&2
  else
    printf "\t%s: \$%s\n" "$ticker" "$price" | lolcat
  fi

  # Clean up
  rm "${ticker}.tkr"
done
