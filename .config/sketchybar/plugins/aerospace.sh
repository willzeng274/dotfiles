#!/usr/bin/env bash

# make sure it's executable with:
# chmod +x ~/.config/sketchybar/plugins/aerospace.sh
source "$CONFIG_DIR/colors.sh"

WORKSPACE_NAME="$1" # The workspace name this script instance is for
MONITOR_ID="$2"   # The monitor ID this workspace item is assigned to (1-based appkit ID)

# Get the workspace that is currently visible on THIS item's specific monitor
# This should return a single workspace name if a monitor shows one workspace at a time.
VISIBLE_WORKSPACE_ON_MONITOR=$(aerospace list-workspaces --monitor "$MONITOR_ID" --visible --format "%{workspace}")

IS_THIS_WORKSPACE_VISIBLE_ON_ITS_MONITOR=false
# Check if VISIBLE_WORKSPACE_ON_MONITOR is not empty and matches WORKSPACE_NAME
if [[ -n "$VISIBLE_WORKSPACE_ON_MONITOR" && "$WORKSPACE_NAME" == "$VISIBLE_WORKSPACE_ON_MONITOR" ]]; then
  IS_THIS_WORKSPACE_VISIBLE_ON_ITS_MONITOR=true
fi

if [ "$SENDER" == "mouse.entered" ]; then
  if [ "$IS_THIS_WORKSPACE_VISIBLE_ON_ITS_MONITOR" = "false" ]; then # Only apply hover if not already visible on its monitor
    sketchybar --set "$NAME" \
      background.drawing=on \
      label.color="$BACKGROUND" \
      icon.color="$BACKGROUND" \
      background.color="$ACCENT_COLOR"
  fi
  exit 0
fi

if [ "$SENDER" == "mouse.exited" ]; then
  if [ "$IS_THIS_WORKSPACE_VISIBLE_ON_ITS_MONITOR" = "false" ]; then # Only remove hover if not visible on its monitor
    sketchybar --set "$NAME" \
      background.drawing=off \
      label.color="$ACCENT_COLOR" \
      icon.color="$ACCENT_COLOR" \
      background.color="$TRANSPARENT"
  fi
  exit 0
fi

# App icon fetching logic
icons=""
# Get app names for this workspace. Ensure APPS_INFO is treated as a literal string by jq.
APPS_INFO_TEXT=$(aerospace list-windows --workspace "$WORKSPACE_NAME" --json --format "%{app-name}")

IFS=$'\n'
# If APPS_INFO_TEXT is an empty JSON array "[]", the loop won't run.
# Use .[]? to safely access array elements and ."app-name"? to safely access the key.
# // empty ensures that if a value is null or an access fails safely, jq outputs nothing for that item.
for app_name in $(echo "$APPS_INFO_TEXT" | jq -r '.[]? | ."app-name"? // empty'); do
  if [ -n "$app_name" ]; then # Ensure app_name is not empty after jq processing
    app_icon=$("$CONFIG_DIR/plugins/icon_map_fn.sh" "$app_name")
    if [ -n "$app_icon" ]; then
      icons+="$app_icon"
      icons+="  " # Padding between icons
    fi
  fi
done
icons=$(echo -e "${icons}" | sed 's/[[:space:]]*$//') # Trim trailing spaces

# Main drawing logic based on whether this workspace is visible on its monitor
if [ "$IS_THIS_WORKSPACE_VISIBLE_ON_ITS_MONITOR" = "true" ]; then
  # This workspace IS VISIBLE on its monitor: Highlight it
  sketchybar --animate sin 10 --set "$NAME" y_offset=10 y_offset=0
  
  sketchybar --set "$NAME" \
    drawing=on \
    label="$icons" \
    label.color="$BACKGROUND" \
    icon.color="$BACKGROUND" \
    background.drawing=on \
    background.color="$ACCENT_COLOR"
else
  # This workspace is NOT VISIBLE on its monitor
  if [ -z "$icons" ]; then
    # Not visible AND empty: hide the item completely
    sketchybar --set "$NAME" drawing=off
  else
    # Not visible BUT has icons: show icons with normal colors, no background highlight
    sketchybar --set "$NAME" \
      drawing=on \
      label="$icons" \
      background.drawing=off \
      label.color="$ACCENT_COLOR" \
      icon.color="$ACCENT_COLOR" \
      background.color="$TRANSPARENT"
  fi
fi
