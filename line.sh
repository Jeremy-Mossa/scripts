#!/bin/ksh

read password < ~/.ssh/grok_password

/usr/bin/chromium-browser --new-window about:blank &

# Wait for Chromium to open
sleep 4

# Move to 3rd workspace (index 2)
wmctrl -r "Chromium" -t 2
sleep 0.25

# Switch to 3rd workspace
wmctrl -s 2
sleep 0.5

# Make Chromium fullscreen (F11)
xdotool search --name "Chromium" key F11

xdotool mousemove 1736 60 click 1
sleep 5
xdotool mousemove 740 560 click 1
sleep 0.5
xdotool type "$password"
sleep 0.5
xdotool key Return
xdotool mousemove 1903 14 click 1
