# Jetson Orin Nano Super Setup

This directory contains configuration and scripts for the Jetson Orin Nano Super, which serves as the central processing unit for the voice changer system.

## Hardware Requirements

- **HDMI Dummy Plug**: Required for headless operation. The graphical session must be active for the user systemd service to work properly.
  - Example: https://amzn.asia/d/6qnBn8m

## Software Environment

### JetPack 6.2.1

| Component | Version |
|-----------|---------|
| JetPack | 6.2.1 |
| L4T (OS) | 36.4.4 (Ubuntu 22.04) |
| CUDA | 12.6 |
| TensorRT | 10.3.0 |
| cuDNN | 9.3.0 |
| PyTorch | 2.8.0 |

Check JetPack version:

```bash
apt show nvidia-jetpack
```

Check CUDA version:

```bash
nvcc --version
```

Check PyTorch version:

```bash
python3 -c "import torch; print(torch.__version__)"
```

Check GPU availability:

```bash
python3 -c "import torch; print('GPU Available:', torch.cuda.is_available()); print('GPU Name:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'None')"
```

Expected output:

```
GPU Available: True
GPU Name: Orin
```

Verify GPU memory access:

```bash
python3 -c "import torch; a = torch.tensor([1.0, 2.0]).cuda(); print('Tensor on GPU:', a.device)"
```

Expected output (`cuda:0` means data is successfully transferred to GPU memory):

```
Tensor on GPU: cuda:0
```

### PyTorch Installation

Install PyTorch 2.8.0 from Jetson AI Lab:

```bash
python3 -m pip install --index-url https://pypi.jetson-ai-lab.io/jp6/cu126 \
  torch torchvision torchaudio
```

Verify PyTorch installation:

```bash
python3 -c "import torch; print('Torch Version:', torch.__version__, ', Torch GPU:', torch.cuda.is_available())"
```

Expected output:

```
Torch Version: 2.8.0 , Torch GPU: True
```

### Python Virtual Environment Setup

```bash
sudo apt install python3.10-venv
python3.10 -m venv .venv --system-site-packages
source .venv/bin/activate
```

### ONNX Runtime Installation (GPU)

Install ONNX Runtime with GPU support from Jetson AI Lab:

```bash
pip install "https://pypi.jetson-ai-lab.io/jp6/cu126/+f/4eb/e6a8902dc7708/onnxruntime_gpu-1.23.0-cp310-cp310-linux_aarch64.whl#sha256=4ebe6a8902dc7708434b2e1541b3fe629ebf434e16ab5537d1d6a622b42c622b"
```

Verify installation:

```bash
python3 -c "import onnxruntime; print('Successfully loaded:', onnxruntime.get_available_providers())"
```

Expected output:

```
Successfully loaded: ['TensorrtExecutionProvider', 'CUDAExecutionProvider', 'CPUExecutionProvider']
```

## Bluetooth Device MAC Addresses

| Device | MAC Address | Bluetooth Name |
|--------|-------------|----------------|
| Button Speaker (BM83) | `2C:FE:8B:20:90:7D` | `BUTTON_SPEAKER` |
| Bowtie Microphone (BM83) | `2C:FE:8B:20:90:43` | `RED_BOWTIE_MIC` |

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

When scanning, devices appear as:

```
[NEW] Device 2C:FE:8B:20:90:43 RED_BOWTIE_MIC
[NEW] Device 2C:FE:8B:20:90:7D BUTTON_SPEAKER
```

## PulseAudio Configuration

### Verify Bluetooth Connection

After connecting, verify the devices are available in PulseAudio:

```bash
pactl list sources short
```

Example output when both devices are connected:

```
0    alsa_output.platform-sound.analog-stereo.monitor    module-alsa-card.c    s16le 2ch 44100Hz    SUSPENDED
1    alsa_input.platform-sound.analog-stereo    module-alsa-card.c    s16le 2ch 44100Hz    SUSPENDED
3    bluez_sink.2C_FE_8B_20_90_7D.a2dp_sink.monitor    module-bluez5-device.c    s16le 2ch 44100Hz    SUSPENDED
4    bluez_sink.2C_FE_8B_20_90_43.handsfree_head_unit.monitor    module-bluez5-device.c    s16le 1ch 16000Hz    SUSPENDED
5    bluez_source.2C_FE_8B_20_90_43.handsfree_head_unit    module-bluez5-device.c    s16le 1ch 16000Hz    SUSPENDED
```

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

### Check Current Default Devices

```bash
pactl info | grep -E 'Default (Sink|Source)'
```

Example output:

```
Default Sink: bluez_sink.2C_FE_8B_20_90_7D.a2dp_sink
Default Source: bluez_source.2C_FE_8B_20_90_43.handsfree_head_unit
```

## Auto-Connect Service Setup (User Systemd)

After Jetson boots, the `~/.local/bin/bt-autoconnect.sh` script runs automatically and:

1. Connects to the bowtie microphone (`RED_BOWTIE_MIC`) via Bluetooth
2. Connects to the button speaker (`BUTTON_SPEAKER`) via Bluetooth
3. Sets the bowtie microphone as the default audio input device
4. Sets the button speaker as the default audio output device

The script checks the connection status every 10 seconds and reconnects if disconnected.

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
