#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# VCClient post-start orchestrator
#
# Goals:
# 1) Always wait 15 seconds after the server process starts (warm-up window).
# 2) After that, poll the server "status" endpoint until it is truly ready.
# 3) Perform the same warm-up GET sequence the browser does.
# 4) POST /operation/start.
# 5) Play a startup sound only if the POST succeeds.
###############################################################################

BASE_URL="http://localhost:18000"
START_WAV="${HOME}/conan-style-voice-changer-mic-speaker/raspi5/sounds/start.wav"

# Warm-up: the process may accept connections but still be initializing.
INITIAL_WAIT_SEC=15

# Polling settings:
# - MAX_WAIT_SEC is the total timeout after the initial 15 seconds.
# - POLL_INTERVAL_SEC is the interval between polls.
MAX_WAIT_SEC=120
POLL_INTERVAL_SEC=1

log() {
  # Use ISO-8601 timestamps for easy journald reading.
  echo "[$(date -Is)] vcclient-autostart: $*"
}

curl_ok() {
  # Wrapper for curl with good defaults for local health checks.
  # -f: fail on HTTP >= 400
  # -sS: silent but show errors
  curl -fsS "$@"
}

wait_initial() {
  log "Initial warm-up sleep: ${INITIAL_WAIT_SEC}s"
  sleep "${INITIAL_WAIT_SEC}"
}

wait_until_ready() {
  log "Polling readiness via GET /api/local-voice-changer-interface/information"
  local deadline=$((SECONDS + MAX_WAIT_SEC))

  while (( SECONDS < deadline )); do
    # We only need the endpoint to respond with HTTP 200 here.
    # The detailed JSON fields vary by version; do not overfit to a specific schema.
    if curl_ok "${BASE_URL}/api/local-voice-changer-interface/information" >/dev/null 2>&1; then
      log "API is responding (information endpoint OK)."
      return 0
    fi
    sleep "${POLL_INTERVAL_SEC}"
  done

  log "ERROR: Timed out waiting for API readiness after ${MAX_WAIT_SEC}s."
  return 1
}

browser_like_warmup() {
  # These calls mirror the sequence seen when opening the UI in a browser.
  # The goal is to force the server to load configuration/devices/slots so that
  # a subsequent POST /operation/start can actually start the pipeline.
  log "Performing browser-like warm-up GET sequence..."

  curl_ok "${BASE_URL}/api/configuration-manager/configuration" >/dev/null || true
  curl_ok "${BASE_URL}/api/audio-device-manager/input_devices"  >/dev/null || true
  curl_ok "${BASE_URL}/api/audio-device-manager/output_devices" >/dev/null || true
  curl_ok "${BASE_URL}/api/gpu-device-manager/devices"          >/dev/null || true
  curl_ok "${BASE_URL}/api/slot-manager/slots"                  >/dev/null || true
  curl_ok "${BASE_URL}/api/server-properties/properties"        >/dev/null || true

  # Read information again after warm-up to ensure internal state is populated.
  curl_ok "${BASE_URL}/api/local-voice-changer-interface/information" >/dev/null || true

  log "Warm-up GET sequence done."
}

start_vcclient() {
  log "POST /api/local-voice-changer-interface/operation/start"
  curl_ok -X POST "${BASE_URL}/api/local-voice-changer-interface/operation/start" >/dev/null
  log "Start command accepted (HTTP 2xx)."
}

play_sound() {
  if command -v pw-play >/dev/null 2>&1; then
    log "Playing startup sound: ${START_WAV}"
    pw-play "${START_WAV}" || log "WARNING: pw-play failed (non-fatal)."
  else
    log "WARNING: pw-play not found; skipping sound."
  fi
}

main() {
  wait_initial
  wait_until_ready
  browser_like_warmup
  start_vcclient
  play_sound
}

main "$@"

