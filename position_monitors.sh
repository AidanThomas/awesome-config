#!/bin/sh

xrandr --output DP-4 --auto
xrandr --output DP-2 --primary --right-of DP-4
xrandr --output DP-0 --primary --right-of DP-2
