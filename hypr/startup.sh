#!/bin/bash
swaybg -i $HOME/Downloads/fondo.jpg &
waybar &
sleep 2
(sleep 2 && hyprctl dispatch workspace 1 && firefox) &
(sleep 3 && hyprctl dispatch workspace 2 && spotify) &
(sleep 4 && hyprctl dispatch workspace 3 && discord) &
