# Jetson Orin Nano Super Setup

This directory contains configuration and scripts for the Jetson Orin Nano Super, which serves as the central processing unit for the voice changer system.

## Hardware Requirements

- **HDMI Dummy Plug**: Required for headless operation. The graphical session must be active for the user systemd service to work properly.
  - Example: https://amzn.asia/d/6qnBn8m

## Bluetooth Device MAC Addresses

| Device | MAC Address |
|--------|-------------|
| Button Speaker (BM83) | `2C:FE:8B:20:90:7D` |
| Bowtie Microphone (BM83) | `2C:FE:8B:20:90:43` |

## Installation

### 1. Install Required Packages

```bash
sudo apt install -y bluetooth bluez bluez-tools pulseaudio pulseaudio-utils pulseaudio-module-bluetooth
```

For ALSA playback testing:

```bash
sudo apt install -y bluez-alsa
```

### 2. Enable Bluetooth Service

```bash
sudo systemctl enable bluetooth
sudo systemctl start bluetooth
systemctl status bluetooth
```

### 3. Fix Jetson Bluetooth Plugin Issue

On Jetson devices, Bluetooth audio plugins (A2DP, AVRCP) are disabled by default. You need to remove the `--noplugin` option.

Edit the configuration file:

```bash
sudo nano /lib/systemd/system/bluetooth.service.d/nv-bluetooth-service.conf
```

Remove `--noplugin=audio,a2dp,avrcp` from the ExecStart line.

Reload and restart the Bluetooth service:

```bash
sudo systemctl daemon-reload
sudo systemctl restart bluetooth
systemctl status bluetooth
```

## Bluetooth Pairing (CLI)

All pairing and connection can be done via CLI using BlueZ (`bluetoothctl`).

```bash
# 1. Start Bluetooth shell
sudo bluetoothctl

# 2. Power on Bluetooth
power on

# 3. Scan for devices (put your device in pairing mode first)
scan on
# Note the MAC address of your device (e.g., XX:XX:XX:XX:XX:XX)
scan off

# 4. Pair with device
pair XX:XX:XX:XX:XX:XX

# 5. Trust device (enables auto-reconnect after reboot)
trust XX:XX:XX:XX:XX:XX

# 6. Connect to device
connect XX:XX:XX:XX:XX:XX
```

## PulseAudio Configuration

### List Available Sinks (Output Devices)

```bash
pactl list short sinks
```

Example output:

```
0    alsa_output.platform-sound.analog-stereo    module-alsa-card.c    s16le 2ch 44100Hz    SUSPENDED
2    bluez_sink.2C_FE_8B_20_90_7D.a2dp_sink    module-bluez5-device.c    s16le 2ch 44100Hz    SUSPENDED
```

### Set Default Output (Speaker)

```bash
pactl set-default-sink bluez_sink.2C_FE_8B_20_90_7D.a2dp_sink
```

### Set Default Input (Microphone)

```bash
pactl set-default-source bluez_source.2C_FE_8B_20_90_43.handsfree_head_unit
```

## Auto-Connect Service Setup (User Systemd)

The `bt-autoconnect.sh` script automatically connects to the Bluetooth speaker and microphone on boot and sets them as default audio devices.

This is configured as a **user-level systemd service** (no root required).

### 1. Create Directories

```bash
mkdir -p ~/.local/bin
mkdir -p ~/.config/systemd/user
```

### 2. Copy Script

```bash
cp bin/bt-autoconnect.sh ~/.local/bin/bt-autoconnect.sh
chmod +x ~/.local/bin/bt-autoconnect.sh
```

### 3. Install User Systemd Service

```bash
cp systemd/bt-autoconnect.service ~/.config/systemd/user/bt-autoconnect.service
```

### 4. Enable and Start Service

```bash
systemctl --user daemon-reload
systemctl --user enable bt-autoconnect.service
systemctl --user start bt-autoconnect.service
```

### 5. Check Service Status

```bash
systemctl --user status bt-autoconnect.service
```

### 6. View Logs

```bash
journalctl --user -u bt-autoconnect.service -f
```

Once the service is running, the Bluetooth speaker and microphone will automatically connect on login and be set as the default audio devices.

## Directory Structure

```
jetson/
├── bin/
│   └── bt-autoconnect.sh    # Auto-connect script
├── systemd/
│   └── bt-autoconnect.service    # Systemd service file
└── README.md
```

## Testing Audio

Test speaker output with ALSA:

```bash
aplay /path/to/test.wav
```

Test with PulseAudio:

```bash
paplay /path/to/test.wav
```
