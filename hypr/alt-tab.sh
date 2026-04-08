#!/bin/bash

current=$(hyprctl activeworkspace -j | jq -r '.id')

chosen=$(hyprctl clients -j | jq -r "
  .[] | select(.workspace.id==$current and .mapped==true) |
  \"\(.class) - \(.title) | \(.address)\"
" | wofi --dmenu | awk -F'|' '{print $2}')

[ -n "$chosen" ] && hyprctl dispatch focuswindow address:$chosen
