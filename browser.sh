#!/bin/bash

mullvad-browser https://grok.com >/dev/null 2>/dev/null &
sleep 2.5
browser_window=$(xdotool search mullvad \
   | tail -n1)
xdotool windowsize $browser_window 68% 94%
xterm -geometry 60x53
