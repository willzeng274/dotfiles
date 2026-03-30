#!/bin/bash

sketchybar --add item aerospace_mode left \
  --subscribe aerospace_mode aerospace_mode_change \
  --set aerospace_mode icon="" \
  script="$CONFIG_DIR/plugins/aerospace_mode.sh" \
  icon.color="$ACCENT_COLOR" \
  icon.padding_left=4 \
  drawing=off

sketchybar --add event aerospace_workspace_change
sketchybar --add event aerospace_window_change
sketchybar --add event aerospace_monitor_change

# Create workspace items — default to drawing=off to avoid flash on reload.
# The controller script will show the correct ones immediately after.
aerospace list-workspaces --all --format "%{workspace}%{tab}%{monitor-appkit-nsscreen-screens-id}" | while IFS=$'\t' read -r sid monitor_appkit_id; do
  if [[ -z "$monitor_appkit_id" || "$monitor_appkit_id" == "0" ]]; then
    monitor_display_id="1"
  else
    monitor_display_id="$monitor_appkit_id"
  fi

  sketchybar --add item space."$sid" left \
    --subscribe space."$sid" mouse.entered mouse.exited \
    --set space."$sid" \
    display="$monitor_display_id" \
    drawing=off \
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
    script="$CONFIG_DIR/plugins/aerospace_hover.sh"
done

# Single controller: handles all heavy events in one batched call
sketchybar --add item aerospace_controller left \
  --subscribe aerospace_controller aerospace_workspace_change aerospace_window_change front_app_switched display_change system_woke aerospace_monitor_change \
  --set aerospace_controller \
  drawing=off \
  script="$CONFIG_DIR/plugins/aerospace.sh"

sketchybar --add item space_separator left \
  --set space_separator icon="|" \
  icon.color="$ACCENT_COLOR" \
  icon.padding_left=4 \
  icon.padding_right=7 \
  label.drawing=off \
  background.drawing=off
