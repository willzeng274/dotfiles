#!/usr/bin/env bash

# Single controller: 2 aerospace calls total.
# Updates ALL workspace items + moves status items to focused monitor
# in one batched sketchybar IPC call.

source "$CONFIG_DIR/colors.sh"

CACHE_DIR="/tmp/sketchybar-aerospace"
mkdir -p "$CACHE_DIR"

# --- 2 aerospace calls total ---

# Call 1: all workspace metadata in one shot
declare -A WS_VISIBLE WS_FOCUSED WS_MONITOR
focused_ws=""
while IFS=$'\t' read -r ws visible focused mid; do
    WS_VISIBLE["$ws"]="$visible"
    WS_FOCUSED["$ws"]="$focused"
    WS_MONITOR["$ws"]="$mid"
    [[ "$focused" == "true" ]] && focused_ws="$ws"
done < <(aerospace list-workspaces --all --format "%{workspace}%{tab}%{workspace-is-visible}%{tab}%{workspace-is-focused}%{tab}%{monitor-appkit-nsscreen-screens-id}" 2>/dev/null)

# Write state for hover script
printf '%s\n' "$focused_ws" > "$CACHE_DIR/focused"
printf '%s\n' "${!WS_VISIBLE[@]}" | tr ' ' '\n' | while read -r ws; do
    [[ "${WS_VISIBLE[$ws]}" == "true" ]] && echo "$ws"
done > "$CACHE_DIR/visible"

# Call 2: app icons per workspace
declare -A WS_ICONS
while IFS=$'\t' read -r ws app_name; do
    icon=$("$CONFIG_DIR/plugins/icon_map_fn.sh" "$app_name")
    [[ -n "$icon" ]] && WS_ICONS["$ws"]+="${icon}  "
done < <(aerospace list-windows --all --format "%{workspace}%{tab}%{app-name}" 2>/dev/null)

# --- Build one batched sketchybar command ---

focused_monitor="${WS_MONITOR[$focused_ws]}"
focused_display="${focused_monitor:-1}"

args=()
focused_item=""

for sid in "${!WS_VISIBLE[@]}"; do
    icons="${WS_ICONS[$sid]}"
    icons="${icons%  }"

    if [[ "${WS_FOCUSED[$sid]}" == "true" ]]; then
        args+=(--set "space.$sid"
            drawing=on
            label="$icons"
            label.color="$BACKGROUND"
            icon.color="$BACKGROUND"
            background.drawing=on
            background.color="$ACCENT_COLOR"
        )
        focused_item="space.$sid"
    elif [[ "${WS_MONITOR[$sid]}" != "$focused_monitor" ]]; then
        # Unfocused monitor: muted with same visual hierarchy
        if [[ "${WS_VISIBLE[$sid]}" == "true" ]]; then
            # Active workspace on unfocused monitor: gray bg
            args+=(--set "space.$sid"
                drawing=on
                label="$icons"
                label.color=0xffcfcfcf
                icon.color=0xffcfcfcf
                background.drawing=on
                background.color=0xff414550
            )
        elif [[ -n "$icons" ]]; then
            # Has windows, not visible, unfocused monitor: gray text, no bg
            args+=(--set "space.$sid"
                drawing=on
                label="$icons"
                label.color=0xff888888
                icon.color=0xff888888
                background.drawing=off
                background.color="$TRANSPARENT"
            )
        else
            args+=(--set "space.$sid" drawing=off)
        fi
    elif [[ -n "$icons" ]]; then
        # Focused monitor, has windows, not visible
        args+=(--set "space.$sid"
            drawing=on
            label="$icons"
            background.drawing=off
            label.color="$ACCENT_COLOR"
            icon.color="$ACCENT_COLOR"
            background.color="$TRANSPARENT"
        )
    else
        args+=(--set "space.$sid" drawing=off)
    fi
done

# Move all status items to the focused monitor's bar
for item in front_app space_separator aerospace_mode calendar volume battery cpu ram wifi caffeinate; do
    args+=(--set "$item" display="$focused_display")
done

[[ ${#args[@]} -gt 0 ]] && sketchybar "${args[@]}"

# Bounce only on workspace switch
if [[ -n "$focused_item" && "$SENDER" == "aerospace_workspace_change" ]]; then
    sketchybar --set "$focused_item" y_offset=8 \
               --animate sin 10 --set "$focused_item" y_offset=0
fi
