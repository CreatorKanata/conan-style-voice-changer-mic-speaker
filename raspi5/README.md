## Spec
- Raspberry Pi5 4GB RAM
- SD: 16GB
- OS: Raspberry Pi OS (64-bit) Bookworm 2025-11-24


## Bluetooth audio device

For demonstration at the JLCPCB booth at NEPCON

| Device | MAC Address |
|--------|-------------|
| BUTTON\_SPEAKER (BM83) | `74:D5:C6:B2:3A:DA` |
| RED\_BOWTIE\_MIC (BM83) | `2C:FE:8B:20:90:7B` |


## Installation

### SSH

```
ssh -A kanata@kanan.local
```

### Update

```
sudo apt update
sudo apt upgrade -y
sudo raspi-config
# Localisation Options -> Locale -> Disable en_GB.UTF-8 and Enable en_US.UTF-8
# Localisation Options -> WLAN Country -> JP
sudo reboot
```

```
sudo apt install vim git
git clone git@github.com:CreatorKanata/conan-style-voice-changer-mic-speaker.git
```

Stop GUI (Optional)

```
sudo systemctl set-default multi-user.target
loginctl enable-linger $USER
```

### Enable Bluetooth

```
sudo vi /etc/bluetooth/main.conf
AutoEnable=true

sudo systemctl restart bluetooth
```

```
bluetoothctl
[bluetoothctl]>
```

```
power on
agent on
default-agent
pairable on
discoverable on
scan on
```

Find BUTTON_SPEAKER and RED_BOWTIE_MIC

```
[NEW] Device 74:D5:C6:B2:3A:DA BUTTON_SPEAKER
[NEW] Device 2C:FE:8B:20:90:7B RED_BOWTIE_MIC
```

Pairing

```
scan off
pair 74:D5:C6:B2:3A:DA
trust 74:D5:C6:B2:3A:DA
connect 74:D5:C6:B2:3A:DA
pair 2C:FE:8B:20:90:7B
trust 2C:FE:8B:20:90:7B
connect 2C:FE:8B:20:90:7B
```

### Audio setting

```
wpctl status
PipeWire 'pipewire-0' [1.4.2, kanata@kanan, cookie:1105578633]
 └─ Clients:
        33. WirePlumber                         [1.4.2, kanata@kanan, pid:1307]
        34. pipewire                            [1.4.2, kanata@kanan, pid:1308]
        43. wpctl                               [1.4.2, kanata@kanan, pid:3101]
        47. WirePlumber [export]                [1.4.2, kanata@kanan, pid:1307]
        73. xdg-desktop-portal                  [1.4.2, kanata@kanan, pid:1531]
        74. xdg-desktop-portal-wlr              [1.4.2, kanata@kanan, pid:1593]
        75. unknown                             [1.4.2, kanata@kanan, pid:1474]

Audio
 ├─ Devices:
 │      48. Built-in Audio                      [alsa]
 │      49. Built-in Audio                      [alsa]
 │      76. BUTTON_SPEAKER                      [bluez5]
 │  
 ├─ Sinks:
 │  *   77. BUTTON_SPEAKER                      [vol: 0.40]
 │  
 ├─ Sources:
 │  
 ├─ Filters:
 │  
 └─ Streams:

Video
 ├─ Devices:
 │      56. rpi-hevc-dec                        [v4l2]
 │      57. pispbe                              [v4l2]
 │      58. pispbe                              [v4l2]
 │      59. pispbe                              [v4l2]
 │      60. pispbe                              [v4l2]
 │      61. pispbe                              [v4l2]
 │      62. pispbe                              [v4l2]
 │      63. pispbe                              [v4l2]
 │      64. pispbe                              [v4l2]
 │      65. pispbe                              [v4l2]
 │      66. pispbe                              [v4l2]
 │      67. pispbe                              [v4l2]
 │      68. pispbe                              [v4l2]
 │      69. pispbe                              [v4l2]
 │      70. pispbe                              [v4l2]
 │      71. pispbe                              [v4l2]
 │      72. pispbe                              [v4l2]
 │  
 ├─ Sinks:
 │  
 ├─ Sources:
 │  
 ├─ Filters:
 │  
 └─ Streams:

Settings
 └─ Default Configured Devices:

```

Test Speaker

```
wpctl set-volume @DEFAULT_AUDIO_SINK@ 1.0
wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.3
pw-play ~/conan-style-voice-changer-mic-speaker/jetson/sounds/test_sp.wav 
```

```
mkdir -p ~/.local/bin
cp ~/conan-style-voice-changer-mic-speaker/jetson/local/ensure-audio-defaults.sh ~/.local/bin/
chmod 755 ~/.local/bin/ensure-audio-defaults.sh
```

```
mkdir -p ~/.config/systemd/user
cp ~/conan-style-voice-changer-mic-speaker/jetson/local/ensure-audio-defaults.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now ensure-audio-defaults.service

systemctl --user restart ensure-audio-defaults.service
systemctl --user status ensure-audio-defaults.service
```

## Download Beatrice vcclient for aarch64

```
mkdir vcclient
cd vcclient
wget https://huggingface.co/wok000/vcclient000/resolve/main/vcclient_std_lin_aarch64_2.2.2-beta_only_beatrice.zip
unzip vcclient_std_lin_aarch64_2.2.2-beta_only_beatrice.zip
cd dist

sudo apt install -y libportaudio2 portaudio19-dev libasound2 libasound2-dev libayatana-appindicator3-1 libappindicator3-1
```

---

### API

Start API

```
cd ~/vcclient/dist
./start_http.sh
```

Start voice changer

```
2026-01-20 02:57:20,221 - uvicorn.ac - h11_impl             - INFO - 192.168.31.81:51223 - "POST /api/local-voice-changer-interface/operation/start HTTP/1.1" 200 - uvicorn/protocols/http/h11_impl.py - 473
```

Change voice character

```
2026-01-20 02:58:56,232 - uvicorn.ac - h11_impl             - INFO - 192.168.31.81:51282 - "PUT /api/slot-manager/slots/0 HTTP/1.1" 200 - uvicorn/protocols/http/h11_impl.py - 473
```

