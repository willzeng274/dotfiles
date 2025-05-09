#!/bin/bash

bar=(
  position=top
  height=35
  blur_radius=30
  color="$BAR_COLOR"
)

sketchybar --bar "${bar[@]}"
