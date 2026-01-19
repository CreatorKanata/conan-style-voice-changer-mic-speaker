#!/bin/bash
set -euo pipefail

###############################################################################
# This script blocks until BOTH the specified speaker (sink) and microphone
# (source) appear in `wpctl status`.
#
# It is designed to be used as ExecStartPre= in a systemd service.
###############################################################################

SINK_NAME="BUTTON_SPEAKER"
SOURCE_NAME="RED_BOWTIE_MIC"
INTERVAL=1

###############################################################################
# Extract numeric PipeWire ID from a status line
###############################################################################
extract_id() {
  sed -n 's/.*[^0-9]\([0-9][0-9]*\)\.\s.*/\1/p' | head -n1
}

###############################################################################
# Find sink ID
###############################################################################
get_sink_id() {
  wpctl status | awk '
    /Sinks:/{f=1;next}
    /Sources:/{f=0}
    f && $0 ~ /'"$SINK_NAME"'/ { print; exit }
  ' | extract_id
}

###############################################################################
# Find source ID
###############################################################################
get_source_id() {
  wpctl status | awk '
    /Sources:/{f=1;next}
    /Filters:/{f=0}
    f && $0 ~ /'"$SOURCE_NAME"'/ { print; exit }
  ' | extract_id
}

###############################################################################
# Poll until both devices exist
###############################################################################
while true; do
  sink="$(get_sink_id || true)"
  source="$(get_source_id || true)"

  if [[ -n "$sink" && -n "$source" ]]; then
    # Both devices are available → exit successfully
    exit 0
  fi

  sleep "$INTERVAL"
done

