#!/bin/bash

librewolf >/dev/null 2>/dev/null &
sleep 0.75
browser_window=$(xdotool search librewolf | tail -n1)
xdotool windowsize $browser_window 68% 94%
xterm -geometry 60x53
