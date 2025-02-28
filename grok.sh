#!/bin/bash

firefox --private-window https://grok.com/?referrer=website 1>/dev/null 2>/dev/null &
sleep 2
browser_window=$(xdotool search grok | tail -n1)
xdotool windowsize $browser_window 68% 94%

