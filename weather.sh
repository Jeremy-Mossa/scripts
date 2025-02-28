#!/bin/bash

city=$1
country=$2
curl -o forecast https://www.timeanddate.com/weather/$country/$city/ext
cat forecast | grep \"date\" > wthr
mv wthr forecast
