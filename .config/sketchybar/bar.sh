#!/bin/bash

bar=(
  position=top
  height=30
  blur_radius=30
  color="$BAR_COLOR"
)

sketchybar --bar "${bar[@]}"
