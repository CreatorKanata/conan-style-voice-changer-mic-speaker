#!/bin/bash
set -euo pipefail

# ===== User-configurable parameters =====
SINK_NAME="BUTTON_SPEAKER"
SOURCE_NAME="RED_BOWTIE_MIC"

# Volume levels (0.0 – 1.0)
SINK_VOLUME="1.0"     # 100%
SOURCE_VOLUME="0.8"   # 80%

# Polling interval in seconds
INTERVAL=1
# ========================================

# Return first numeric ID (e.g. 45) from a wpctl status section line,
# even if it starts with '*'
extract_id() {
  sed -n 's/.*[^0-9]\([0-9][0-9]*\)\.\s.*/\1/p' | head -n1
}

get_sink_id() {
  wpctl status | awk '
    /Sinks:/{f=1;next}
    /Sources:/{f=0}
    f && $0 ~ /'"$SINK_NAME"'/ { print; exit }
  ' | extract_id
}

get_source_id() {
  wpctl status | awk '
    /Sources:/{f=1;next}
    /Filters:/{f=0}
    f && $0 ~ /'"$SOURCE_NAME"'/ { print; exit }
  ' | extract_id
}

last_sink=""
last_source=""

while true; do
  sink="$(get_sink_id || true)"
  source="$(get_source_id || true)"

  if [[ -n "${sink}" && -n "${source}" ]]; then
    if [[ "$sink" != "$last_sink" ]]; then
      wpctl set-default "$sink" || true
      wpctl set-volume "$sink" "$SINK_VOLUME" || true
      last_sink="$sink"
    fi

    if [[ "$source" != "$last_source" ]]; then
      wpctl set-default "$source" || true
      wpctl set-volume "$source" "$SOURCE_VOLUME" || true
      last_source="$source"
    fi
  fi

  sleep "$INTERVAL"
done

