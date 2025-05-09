# #!/bin/bash
#
# sketchybar --add item wifi right \
#   --subscribe wifi wifi_change \
#   --set wifi \
#   script="$PLUGIN_DIR/wifi.sh"


#!/bin/bash

wifi=(
    update_freq=5
    script="$PLUGIN_DIR/wifi.sh"
)

sketchybar --add item wifi right \
    --set wifi "${wifi[@]}" \
    --subscribe wifi wifi_change
