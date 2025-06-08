#!/bin/bash

# List of stock tickers
tickers=(
  # Monthly Payers (REITs, Financials, Utilities)
  "O"      # Realty Income (REIT, Dividend Achiever, 30+ years increases)
  "STAG"   # STAG Industrial (REIT, industrial properties)
  "ADC"    # Agree Realty (REIT, retail properties)
  "EPR"    # EPR Properties (REIT, entertainment venues)
  "MAIN"   # Main Street Capital (BDC, high yield, financials)
  "PSEC"   # Prospect Capital (BDC, diversified investments)
  "SLG"    # SL Green Realty (REIT, NYC office properties)
  "APLE"   # Apple Hospitality REIT (hotels)
  "AGNC"   # AGNC Investment (mortgage REIT, high yield)
  "ARR"    # ARMOUR Residential REIT (mortgage REIT)
  "GOOD"   # Gladstone Commercial (REIT, industrial/office)
  "GLAD"   # Gladstone Capital (BDC, small business loans)
  "LTC"    # LTC Properties (REIT, senior housing)
  "PEI"    # Pennsylvania REIT (retail properties)
  "GAIN"   # Gladstone Investment (BDC, buyouts)
  "HRZN"   # Horizon Technology Finance (venture loans)
  "PFLT"   # PennantPark Floating Rate Capital (BDC)
  "FSK"    # FS KKR Capital (BDC, private credit)
  "OXLC"   # Oxford Lane Capital (CLO investments)
  "ECC"    # Eagle Point Credit (CLO equity)
  # Buffett-Style Quarterly Payers (Dividend Kings, Strong Moats)
  "KO"     # Coca-Cola (Dividend King, 62+ years, Buffett holding)[](https://www.kiplinger.com/investing/stocks/best-warren-buffett-dividend-stocks)
  "CVX"    # Chevron (37+ years, energy, Buffett holding)[](https://www.bankrate.com/investing/warren-buffett-top-stock-picks-of-all-time/)
  "AXP"    # American Express (Buffett holding since 1991)[](https://www.forbes.com/advisor/investing/best-warren-buffett-stocks/)
  "BAC"    # Bank of America (Buffett holding, financials)[](https://www.bankrate.com/investing/warren-buffett-dividend-stocks/)
  "KHC"    # Kraft Heinz (Buffett holding, consumer staples)[](https://stockcircle.com/portfolio/warren-buffett)
  "C"      # Citigroup (Buffett holding, financials)[](https://www.bankrate.com/investing/warren-buffett-dividend-stocks/)
  "KR"     # Kroger (supermarkets, Buffett holding)[](https://www.bankrate.com/investing/warren-buffett-dividend-stocks/)
  "CB"     # Chubb (insurance, Buffett holding)[](https://www.bankrate.com/investing/warren-buffett-dividend-stocks/)
  "ALLY"   # Ally Financial (Buffett holding, financials)[](https://www.simplysafedividends.com/world-of-dividends/posts/4-warren-buffett-s-dividend-portfolio)
  "SIRI"   # Sirius XM (Buffett holding, media)[](https://finance.yahoo.com/news/10-warren-buffett-dividend-stocks-145741482.html)
  "JNJ"    # Johnson & Johnson (Dividend King, 60+ years)
  "PG"     # Procter & Gamble (Dividend King, 60+ years)
  "CL"     # Colgate-Palmolive (Dividend King, 50+ years)
  "MMM"    # 3M (Dividend King, 60+ years)
  "TGT"    # Target (Dividend Achiever, retail)[](https://www.fool.com/investing/stock-market/types-of-stocks/dividend-stocks/)
  "LOW"    # Lowe’s (Dividend King, 50+ years)[](https://www.kiplinger.com/investing/stocks/dividend-stocks/best-dividend-stocks-you-can-count-on)
  "ADP"    # Automatic Data Processing (50+ years)[](https://www.kiplinger.com/investing/stocks/dividend-stocks/best-dividend-stocks-you-can-count-on)
  "LIN"    # Linde (25+ years, industrial gases)[](https://www.kiplinger.com/investing/stocks/dividend-stocks/best-dividend-stocks-you-can-count-on)
  "CHD"    # Church & Dwight (consumer staples)[](https://www.kiplinger.com/investing/stocks/dividend-stocks/best-dividend-stocks-you-can-count-on)
  "ED"     # Consolidated Edison (utility, stable)[](https://www.kiplinger.com/investing/stocks/dividend-stocks/best-dividend-stocks-you-can-count-on)
  "IBM"    # IBM (tech, Dividend Aristocrat)[](https://www.kiplinger.com/investing/stocks/dividend-stocks/best-dividend-stocks-you-can-count-on)
  "PEP"    # PepsiCo (Dividend King, 50+ years)
  "WMT"    # Walmart (retail, Dividend Aristocrat)
  "MCD"    # McDonald’s (Dividend Aristocrat, fast food)
  "XOM"    # ExxonMobil (37+ years, energy)
  "CAT"    # Caterpillar (Dividend Aristocrat, machinery)
  "EMR"    # Emerson Electric (Dividend King, 60+ years)
  "NEE"    # NextEra Energy (utility, renewable focus)
  "MO"     # Altria Group (tobacco, high yield)
  "PM"     # Philip Morris (tobacco, global focus)
)
for ticker in "${tickers[@]}"; do
  # Fetch quotes and save to temporary file
  gnucash-cli --quotes dump yahooweb \
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
