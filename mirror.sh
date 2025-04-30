#!/bin/bash

while true; do
  adb exec-out screencap -p > /tmp/game.png
  sleep 10
done &

sleep 4  # Ensure the first screenshot is taken
feh -R 10 --zoom 25 /tmp/game.png
kill %1  # Stop the background job
