#!/bin/bash

sketchybar --add item aerospace_mode left \
  --subscribe aerospace_mode aerospace_mode_change \
  --set aerospace_mode icon="" \
  script="$CONFIG_DIR/plugins/aerospace_mode.sh" \
  icon.color="$ACCENT_COLOR" \
  icon.padding_left=4 \
  drawing=off

# Use a pipe and while read loop for robustness with workspace names and to get monitor IDs
aerospace list-workspaces --all --format "%{workspace}%{tab}%{monitor-appkit-nsscreen-screens-id}" | while IFS=$'\t' read -r sid monitor_appkit_id; do
  # If monitor_appkit_id is empty or zero, default to "1" (main display for SketchyBar)
  # AeroSpace's monitor-appkit-nsscreen-screens-id is 1-based.
  if [[ -z "$monitor_appkit_id" || "$monitor_appkit_id" == "0" ]]; then
    monitor_display_id="1" # Fallback, though appkit IDs should be valid and 1-based
  else
    monitor_display_id="$monitor_appkit_id"
  fi

  sketchybar --add item space."$sid" left \
    --subscribe space."$sid" aerospace_workspace_change display_change system_woke mouse.entered mouse.exited \
    --set space."$sid" \
    display="$monitor_display_id" \
    padding_right=0 \
    icon="$sid" \
    label.padding_right=7 \
    icon.padding_left=7 \
    icon.padding_right=4 \
    background.drawing=on \
    label.font="sketchybar-app-font:Regular:16.0" \
    background.color="$ACCENT_COLOR" \
    icon.color="$BACKGROUND" \
    label.color="$BACKGROUND" \
    background.corner_radius=5 \
    background.height=25 \
    label.drawing=on \
    click_script="aerospace workspace \"$sid\"" \
    script="$CONFIG_DIR/plugins/aerospace.sh \"$sid\" \"$monitor_display_id\""
done

sketchybar --add item space_separator left \
  --set space_separator icon="|" \
  icon.color="$ACCENT_COLOR" \
  icon.padding_left=4 \
  icon.padding_right=7 \
  label.drawing=off \
  background.drawing=off

