#!/bin/sh

xrandr --output DP-4 --mode 2560x1440 --rate 143.97 --auto
xrandr --output DP-2 --mode 2560x1440 --rate 143.97 --primary --right-of DP-4
xrandr --output DP-0 --mode 2560x1440 --rate 143.97 --primary --right-of DP-2
