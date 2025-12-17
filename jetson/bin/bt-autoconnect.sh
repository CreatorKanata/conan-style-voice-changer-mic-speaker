#!/bin/bash

SP_DEV="2C:FE:8B:20:90:7D"
MIC_DEV="2C:FE:8B:20:90:43"
INTERVAL=10        # Check every 10 seconds

# Convert MAC address colons to underscores for pactl sink/source names
SP_SINK="bluez_sink.${SP_DEV//:/_}.a2dp_sink"
MIC_SOURCE="bluez_source.${MIC_DEV//:/_}.handsfree_head_unit"

# Function that returns 0 only when "Connection successful" is actually returned
bt_connect() {
    local dev="$1"
    # Capture bluetoothctl output to variable
    out=$(bluetoothctl connect "$dev" 2>&1)
    echo "$out"
    # Return success if the output contains success message
    if echo "$out" | grep -q "Connection successful"; then
        return 0
    fi
    return 1
}

sleep 3
bluetoothctl power on

while true; do
    # ===== Speaker =====
    if bluetoothctl info "$SP_DEV" | grep -q "Connected: yes"; then
        echo "$(date) - already connected to SP ($SP_DEV)"
    else
        echo "$(date) - SP not connected, trying to connect..."
        if bt_connect "$SP_DEV"; then
            echo "$(date) - SP connection OK"
            # Set default sink only when connection succeeds
            pactl set-default-sink "$SP_SINK"
            # Test playback
            aplay /home/hide/conan-style-voice-changer-mic-speaker/jetson/sounds/test_sp.wav

            if bt_connect "$MIC_DEV"; then
		sleep 2
                pactl set-default-source "$MIC_SOURCE"
            fi
        else
            echo "$(date) - SP connection failed"
        fi
    fi

    # ===== Microphone =====
    if bluetoothctl info "$MIC_DEV" | grep -q "Connected: yes"; then
        echo "$(date) - already connected to MIC ($MIC_DEV)"
    else
        echo "$(date) - MIC not connected, trying to connect..."
        if bt_connect "$MIC_DEV"; then
            echo "$(date) - MIC connection OK"
            # Set default source only when connection succeeds
            pactl set-default-source "$MIC_SOURCE"
            # Test sound (actually plays through speaker since it's audio playback)
            aplay /home/hide/conan-style-voice-changer-mic-speaker/jetson/sounds/test_mic.wav

            if bt_connect "$SP_DEV"; then
		sleep 2
                pactl set-default-sink "$SP_SINK"
	    fi
        else
            echo "$(date) - MIC connection failed"
        fi
    fi

    sleep "$INTERVAL"
done

