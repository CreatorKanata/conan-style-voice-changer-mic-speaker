# Implementation Plan

## Current Status

### Completed

- [x] Bowtie microphone PCB design (BM83 + MEMS mic)
- [x] Button speaker PCB design (BM83 + speaker)
- [x] 3D case design for bowtie microphone
- [x] 3D case design for button speaker
- [x] Schematic documentation (PDF)

### In Progress

- [x] Raspberry Pi 5 setup and configuration
- [x] Voice changer implementation (Beatrice)
- [ ] Real-time translation implementation (Gemini Live API)

## Implementation Steps

### Phase 1: Raspberry Pi 5 Environment Setup

#### 1.1 System Configuration

- [x] Install Raspberry Pi OS (64-bit) Bookworm
- [x] Configure system locale and WLAN
- [x] Install required packages

#### 1.2 Bluetooth Audio Setup

- [x] Configure PipeWire for Bluetooth
- [x] Pair BM83 microphone (HFP profile)
- [x] Pair BM83 speaker (A2DP profile)
- [x] Configure audio routing (mic input → processing → speaker output)
- [x] Test Bluetooth auto-reconnection on boot

#### 1.3 Audio Pipeline

- [x] Set up audio capture from HFP source
- [x] Configure sample rate and buffer settings for low latency
- [x] Set up audio output to A2DP sink
- [x] Test end-to-end audio passthrough

### Phase 2: Voice Changer (Beatrice)

#### 2.1 voice-changer Setup

- [x] Download voice-changer (vcclient) for aarch64
- [x] Install required dependencies
- [x] Test basic voice conversion

#### 2.2 Real-time Processing

- [x] Configure voice-changer for real-time inference
- [x] Optimize buffer sizes for minimum latency
- [x] Implement voice model switching via API

#### 2.3 Integration

- [x] Connect Bluetooth input to voice-changer
- [x] Connect voice-changer output to Bluetooth speaker
- [x] Test end-to-end voice changing
- [ ] Measure and optimize latency

### Phase 3: Real-time Translation

#### 3.1 Gemini Live API Setup

- [ ] Set up Google Cloud credentials
- [ ] Implement Gemini Live API client
- [ ] Test speech-to-text in Japanese
- [ ] Test translation to English

#### 3.2 Text-to-Speech Integration

- [ ] Implement TTS for translated text
- [ ] Integrate with voice changer for consistent output
- [ ] Test end-to-end translation pipeline

#### 3.3 Mode Switching

- [ ] Implement mode selection (voice change only / translation)
- [ ] Add physical button or gesture control (optional)
- [ ] Create configuration interface

### Phase 4: System Integration

#### 4.1 Startup and Auto-run

- [x] Create systemd service for voice changer
- [x] Configure auto-start on boot
- [x] Implement graceful shutdown handling
- [x] Add logging and monitoring

#### 4.2 Power Management

- [ ] Optimize for power efficiency
- [ ] Implement sleep/wake functionality
- [ ] Battery monitoring for peripherals (future)

#### 4.3 Testing and Refinement

- [ ] End-to-end testing with all components
- [ ] Latency measurement and optimization
- [ ] User experience testing
- [ ] Bug fixes and stability improvements

## Directory Structure

```
raspi5/
├── local/
│   ├── ensure-audio-defaults.sh    # Audio device monitoring script
│   ├── ensure-audio-defaults.service
│   ├── wait-for-audio-devices.sh   # Wait for BT devices script
│   ├── vcclient-autostart.sh       # Voice changer auto-start script
│   └── vcclient.service            # Systemd service file
├── sounds/
│   ├── test_sp.wav                 # Speaker test sound
│   ├── test_mic.wav                # Microphone test sound
│   └── start.wav                   # Startup sound
└── README.md                       # Setup instructions
```

## Technical Specifications

### Audio Pipeline

- Sample Rate: 16kHz for speech processing, 48kHz for output
- Buffer Size: ~20-40ms for low latency
- Format: PCM 16-bit

### Latency Targets

- Voice Changer: < 100ms end-to-end
- Translation: < 500ms for real-time feel

### Hardware Requirements

- Raspberry Pi 5 (4GB RAM)
- BM83 Bluetooth modules (pre-paired)
- Stable power supply
- SD card (16GB+)

## Dependencies

### voice-changer (vcclient)

- Download from: https://github.com/w-okada/voice-changer
- Use aarch64 version with Beatrice support

### System Packages

- PipeWire (audio server)
- BlueZ (Bluetooth stack)
- libportaudio2, portaudio19-dev
- libasound2, libasound2-dev
- libayatana-appindicator3-1, libappindicator3-1

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| High latency | Optimize buffer sizes, use Beatrice (CPU-optimized) |
| Bluetooth instability | Implement reconnection logic with systemd services |
| CPU constraints | Use Beatrice model optimized for ARM |
| Power consumption | Use efficient inference settings |

## Success Criteria

1. Voice changing works with < 100ms latency
2. Translation mode provides usable real-time output
3. System starts automatically and runs stably
4. Bluetooth devices reconnect automatically
5. Audio quality is clear and intelligible
