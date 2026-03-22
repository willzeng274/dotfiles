#!/usr/bin/env bash

# make sure it's executable with:
# chmod +x ~/.config/sketchybar/plugins/aerospace.sh
source "$CONFIG_DIR/colors.sh"

WORKSPACE_NAME="$1" # The workspace name this script instance is for

# Fast path for hover events — avoid the expensive multi-monitor loop entirely.
# Use a single `--monitor focused --visible` call instead.
if [ "$SENDER" == "mouse.entered" ]; then
  FOCUSED_WS=$(aerospace list-workspaces --monitor focused --visible 2>/dev/null | head -1 | tr -d '[:space:]')
  if [ "$WORKSPACE_NAME" != "$FOCUSED_WS" ]; then
    sketchybar --set "$NAME" \
      background.drawing=on \
      label.color="$BACKGROUND" \
      icon.color="$BACKGROUND" \
      background.color="$ACCENT_COLOR"
  fi
  exit 0
fi

if [ "$SENDER" == "mouse.exited" ]; then
  FOCUSED_WS=$(aerospace list-workspaces --monitor focused --visible 2>/dev/null | head -1 | tr -d '[:space:]')
  if [ "$WORKSPACE_NAME" != "$FOCUSED_WS" ]; then
    sketchybar --set "$NAME" \
      background.drawing=off \
      label.color="$ACCENT_COLOR" \
      icon.color="$ACCENT_COLOR" \
      background.color="$TRANSPARENT"
  fi
  exit 0
fi

# For window/app changes: only the focused workspace needs to refresh its icons.
# All other spaces exit early — one fast check, no monitor loop.
if [ "$SENDER" == "aerospace_window_change" ] || [ "$SENDER" == "front_app_switched" ]; then
  FOCUSED_WS=$(aerospace list-workspaces --monitor focused --visible 2>/dev/null | head -1 | tr -d '[:space:]')
  if [ "$WORKSPACE_NAME" != "$FOCUSED_WS" ]; then
    exit 0
  fi
  # Refresh icons for this workspace only — visibility state hasn't changed
  icons=""
  APPS_INFO_TEXT=$(aerospace list-windows --workspace "$WORKSPACE_NAME" --json --format "%{app-name}")
  IFS=$'\n'
  for app_name in $(echo "$APPS_INFO_TEXT" | jq -r '.[]? | ."app-name"? // empty'); do
    if [ -n "$app_name" ]; then
      app_icon=$("$CONFIG_DIR/plugins/icon_map_fn.sh" "$app_name")
      if [ -n "$app_icon" ]; then
        icons+="$app_icon"
        icons+="  "
      fi
    fi
  done
  icons=$(echo -e "${icons}" | sed 's/[[:space:]]*$//')
  sketchybar --set "$NAME" label="$icons" drawing=on background.drawing=on
  exit 0
fi

# For all other events (workspace change, display change, system wake):
# do the full multi-monitor visibility check.
IS_THIS_WORKSPACE_VISIBLE_ON_ITS_MONITOR=false
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

if echo "$VISIBLE_WORKSPACES" | grep -q "^${WORKSPACE_NAME}$"; then
  IS_THIS_WORKSPACE_VISIBLE_ON_ITS_MONITOR=true
fi

# App icon fetching
icons=""
APPS_INFO_TEXT=$(aerospace list-windows --workspace "$WORKSPACE_NAME" --json --format "%{app-name}")

IFS=$'\n'
for app_name in $(echo "$APPS_INFO_TEXT" | jq -r '.[]? | ."app-name"? // empty'); do
  if [ -n "$app_name" ]; then
    app_icon=$("$CONFIG_DIR/plugins/icon_map_fn.sh" "$app_name")
    if [ -n "$app_icon" ]; then
      icons+="$app_icon"
      icons+="  "
    fi
  fi
done
icons=$(echo -e "${icons}" | sed 's/[[:space:]]*$//')

# Main drawing logic
if [ "$IS_THIS_WORKSPACE_VISIBLE_ON_ITS_MONITOR" = "true" ]; then
  # Set appearance and jump up, then animate back down — actual bounce
  sketchybar --set "$NAME" \
    y_offset=8 \
    drawing=on \
    label="$icons" \
    label.color="$BACKGROUND" \
    icon.color="$BACKGROUND" \
    background.drawing=on \
    background.color="$ACCENT_COLOR"
  sketchybar --animate sin 10 --set "$NAME" y_offset=0
else
  if [ -z "$icons" ]; then
    sketchybar --set "$NAME" drawing=off
  else
    sketchybar --set "$NAME" \
      drawing=on \
      label="$icons" \
      background.drawing=off \
      label.color="$ACCENT_COLOR" \
      icon.color="$ACCENT_COLOR" \
      background.color="$TRANSPARENT"
  fi
fi