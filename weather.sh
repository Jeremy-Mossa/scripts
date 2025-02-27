#!/bin/bash

city=$1
curl -o forecast https://www.timeanddate.com/weather/usa/$city/ext
cat forecast | grep \"date\" > wthr
mv wthr forecast
