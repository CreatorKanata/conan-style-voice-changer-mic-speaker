#!/bin/bash
set -euo pipefail

###############################################################################
# This script continuously monitors PipeWire audio devices using `wpctl`.
#
# Behavior:
# - When the specified speaker (sink) is newly connected:
#   - Set it as the default sink
#   - Set its volume
#   - Play a speaker test sound after 1 second
#
# - When the specified microphone (source) is newly connected:
#   - Set it as the default source
#   - Set its volume
#   - Play a microphone test sound after 1 second
#
# - If either device is disconnected, the internal state is reset so that
#   reconnection is detected again.
###############################################################################

# ===== User-configurable parameters ==========================================

# Human-readable names shown in `wpctl status`
SINK_NAME="BUTTON_SPEAKER"
SOURCE_NAME="RED_BOWTIE_MIC"

# Volume levels (0.0 – 1.0)
SINK_VOLUME="1.0"     # 100% output volume
SOURCE_VOLUME="0.8"   # 80% input volume

# Paths to test sound files
SOUND_TEST_SPK="$HOME/conan-style-voice-changer-mic-speaker/raspi5/sounds/test_sp.wav"
SOUND_TEST_MIC="$HOME/conan-style-voice-changer-mic-speaker/raspi5/sounds/test_mic.wav"

# Polling interval in seconds
INTERVAL_SP=2
INTERVAL_MIC=0.5
INTERVAL=1

# ============================================================================


###############################################################################
# extract_id
# Extracts the numeric PipeWire ID from a `wpctl status` line.
#
# Example input:
#   "* 45. USB Audio Device ..."
# Output:
#   45
###############################################################################
extract_id() {
  sed -n 's/.*[^0-9]\([0-9][0-9]*\)\.\s.*/\1/p' | head -n1
}

###############################################################################
# get_sink_id
# Searches the "Sinks" section of `wpctl status` and returns the ID
# of the sink matching SINK_NAME.
###############################################################################
get_sink_id() {
  wpctl status | awk '
    /Sinks:/{f=1;next}
    /Sources:/{f=0}
    f && $0 ~ /'"$SINK_NAME"'/ { print; exit }
  ' | extract_id
}

###############################################################################
# get_source_id
# Searches the "Sources" section of `wpctl status` and returns the ID
# of the source matching SOURCE_NAME.
###############################################################################
get_source_id() {
  wpctl status | awk '
    /Sources:/{f=1;next}
    /Filters:/{f=0}
    f && $0 ~ /'"$SOURCE_NAME"'/ { print; exit }
  ' | extract_id
}

###############################################################################
# play_after_sec
# Plays a WAV file after a X-second delay.
# Executed in the background so it never blocks the main loop.
###############################################################################
play_after_sec() {
  local wav="$1"
  local wait_sec="$2"
  (
    sleep $wait_sec
    pw-play "$wav" >/dev/null 2>&1
  ) &
}

# Track previously-detected device IDs
last_sink=""
last_source=""

###############################################################################
# Main polling loop
###############################################################################
while true; do
  sink="$(get_sink_id || true)"
  source="$(get_source_id || true)"

  # If both devices exist
  if [[ -n "$sink" && -n "$source" ]]; then

    # Speaker newly connected
    if [[ "$sink" != "$last_sink" ]]; then
      wpctl set-default "$sink" || true
      wpctl set-volume "$sink" "$SINK_VOLUME" || true
      last_sink="$sink"

      # Play speaker test sound after 1 second
      play_after_sec "$SOUND_TEST_SPK" "$INTERVAL_SP"
    fi

    # Microphone newly connected
    if [[ "$source" != "$last_source" ]]; then
      wpctl set-default "$source" || true
      wpctl set-volume "$source" "$SOURCE_VOLUME" || true
      last_source="$source"

      # Play microphone test sound after 1 second
      play_after_sec "$SOUND_TEST_MIC" "$INTERVAL_MIC"
    fi

  else
    # If either device disappears, reset state so reconnection is detected
    [[ -z "$sink" ]] && last_sink=""
    [[ -z "$source" ]] && last_source=""
  fi

  sleep "$INTERVAL"
done

