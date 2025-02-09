#!/bin/bash

cat ~/scripts/area-codes.html | grep "area-code-$1" | cut -d',' -f1 | cut -d'/' -f6
