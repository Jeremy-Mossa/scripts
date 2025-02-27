#!/bin/bash

gnucash-cli --quotes dump yahooweb \
  wolf 2>/dev/null > wolf.tkr

price=$(grep last wolf.tkr \
  | cut -d':' -f2 \
  | cut -d'<' -f1 \
  | sed 's/^[ ]*//')
printf "\tWOLF: \$$price\n" | lolcat

rm wolf.tkr
