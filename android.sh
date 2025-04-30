#!/bin/bash


sudo adb kill-server
sleep 0.5
sudo adb devices
wait

if $(adb shell dumpsys window \
  2>/dev/null | \
  grep -q 'Lockscreen=true'); then
 
  # Unlock android device
  adb shell input keyevent 82
  sleep 0.25
  adb shell input swipe 300 1000 300 500
  sleep 0.25
  adb shell input text "071981"
fi

if $(adb shell pidof com.kabam.marvelbattle); then
  echo "MCoC already running"

  else
    # Start MCoC
    adb shell monkey -p com.kabam.marvelbattle 1
    sleep 1
fi

# How to take a screenpic without saving
# on the android device
# adb exec-out screencap -p > /dir/screenpic.png

while true; do
  if ! $(adb shell pidof com.kabam.marvelbattle); then
    break
  fi
  adb exec-out screencap -p /tmp/game.png
  sleep 10
done &

feh -R 10 /tmp/game.png
