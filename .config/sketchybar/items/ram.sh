#!/bin/bash

sketchybar --add item ram right \
  --set ram update_freq=3 \
  icon=\
  padding_left=0 \
  script="$PLUGIN_DIR/ram.sh"
