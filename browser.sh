#!/bin/sh

mullvad-browser https://www.meta.ai \
  >/dev/null 2>/dev/null &
sleep 2

browser_window=$(xdotool search --name \
   "Mullvad" | tail -n1)
xdotool windowsize $browser_window 68% 94%
xterm -geometry 60x53


sleep 12
xdotool mousemove 458 458 
xdotool click 1
sleep 1
xdotool type "hey"
sleep 0.25

xdotool mousemove 948 540 click 1
sleep 0.25
xdotool mousemove 852 664 click 1
sleep 0.25
xdotool mousemove 700 500 
sleep 0.25

xdotool click --repeat 10 5
sleep 0.25
xdotool click 1
sleep 0.25
xdotool enter Return
sleep 0.25
xdotool mousemove 730 730
sleep 0.25
xdotool click 1
xdotool click 1
