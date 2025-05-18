#!/bin/sh

# Start Xvfb on display :99 and store the PID
Xvfb :99 -screen 0 1024x768x24 >/dev/null 2>&1 &
XVFB_PID=$!

# Wait for Xvfb to start
sleep 2

# Set the DISPLAY environment variable
export DISPLAY=:99

url='https://store.playcontestofchampions.com'

# Launch Firefox on the virtual display
firefox --private-window $url \
  >/dev/null 2>&1 &

# Wait for Firefox to load
sleep 10

# Capture a screenshot of the virtual display
import -window root /home/jbm/pics/rewards.png

# Use xdotool to simulate interactions on the virtual display
# Adjust the window search command to match the actual window title
xdotool search --onlyvisible --class firefox windowactivate --sync
xdotool mousemove x y click 1
xdotool type "your_email"
xdotool key Tab
xdotool type "your_password"
xdotool key Return

# Kill the Xvfb server
kill $XVFB_PID

# Alternatively, you can use pkill to kill Xvfb
# pkill Xvfb
