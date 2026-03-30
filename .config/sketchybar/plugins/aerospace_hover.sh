#!/usr/bin/env bash
# Zero aerospace calls. Reads cached state from /tmp written by the controller.
source "$CONFIG_DIR/colors.sh"

WS="${NAME#space.}"
CACHE_DIR="/tmp/sketchybar-aerospace"

case "$SENDER" in
  mouse.entered)
    # Skip hover for visible workspaces (focused + active on other monitors)
    grep -qx "$WS" "$CACHE_DIR/visible" 2>/dev/null && exit 0
    sketchybar --set "$NAME" \
      background.drawing=on \
      label.color="$BACKGROUND" \
      icon.color="$BACKGROUND" \
      background.color=0xffe8b830
    ;;
  mouse.exited)
    # Skip restore for visible workspaces (they should keep active styling)
    grep -qx "$WS" "$CACHE_DIR/visible" 2>/dev/null && exit 0
    sketchybar --set "$NAME" \
      background.drawing=off \
      label.color="$ACCENT_COLOR" \
      icon.color="$ACCENT_COLOR" \
      background.color="$TRANSPARENT"
    ;;
esac
