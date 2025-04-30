#!/bin/bash


if $(adb shell dumpsys window | \
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
fi
