#!/usr/bin/env bash

# make sure it's executable with:
# chmod +x ~/.config/sketchybar/plugins/aerospace.sh
source "$CONFIG_DIR/colors.sh"

WORKSPACE_NAME="$1" # The workspace name this script instance is for
# NOTE: $2 (MONITOR_ID) is ignored - we dynamically query the current monitor for this workspace

# Check if this workspace is currently visible on any monitor
IS_THIS_WORKSPACE_VISIBLE_ON_ITS_MONITOR=false

# Get all visible workspaces across all monitors
# Query each monitor for its visible workspace
VISIBLE_WORKSPACES=""
MONITOR_LIST=$(aerospace list-monitors 2>/dev/null)
while IFS= read -r line; do
  monitor_id=$(echo "$line" | cut -d'|' -f1 | xargs)
  if [[ -n "$monitor_id" ]]; then
    # Redirect stdin from /dev/null to prevent aerospace from consuming the while loop's stdin
    visible_ws=$(aerospace list-workspaces --monitor "$monitor_id" --visible < /dev/null 2>/dev/null)
    if [[ -n "$visible_ws" ]]; then
      VISIBLE_WORKSPACES+="$visible_ws"$'\n'
    fi
  fi
done <<< "$MONITOR_LIST"

# Check if our workspace is in the list of visible workspaces
if echo "$VISIBLE_WORKSPACES" | grep -q "^${WORKSPACE_NAME}$"; then
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

# Handle display changes and system wake events
# When monitors are connected/disconnected or system wakes, we need to refresh
# These events don't need special handling - just fall through to update the display
if [ "$SENDER" == "display_change" ] || [ "$SENDER" == "system_woke" ]; then
  # Fall through to the main update logic below
  :
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