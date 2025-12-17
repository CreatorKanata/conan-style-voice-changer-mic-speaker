# Implementation Plan

## Current Status

### Completed

- [x] Bowtie microphone PCB design (BM83 + MEMS mic)
- [x] Button speaker PCB design (BM83 + speaker)
- [x] 3D case design for bowtie microphone
- [x] 3D case design for button speaker
- [x] Schematic documentation (PDF)

### In Progress

- [ ] Jetson Orin Nano Super setup and configuration
- [ ] Voice changer implementation (RVC)
- [ ] Real-time translation implementation (Gemini Live API)

## Implementation Steps

### Phase 1: Jetson Environment Setup

#### 1.1 System Configuration

- [ ] Install JetPack SDK (latest version for Orin Nano Super)
- [ ] Configure CUDA and TensorRT
- [ ] Set up Python virtual environment

#### 1.2 Bluetooth Audio Setup

- [ ] Configure PulseAudio/PipeWire for Bluetooth
- [ ] Pair BM83 microphone (HFP profile)
- [ ] Pair BM83 speaker (A2DP profile)
- [ ] Configure audio routing (mic input → processing → speaker output)
- [ ] Test Bluetooth auto-reconnection on boot

#### 1.3 Audio Pipeline

- [ ] Set up audio capture from HFP source
- [ ] Configure sample rate and buffer settings for low latency
- [ ] Set up audio output to A2DP sink
- [ ] Test end-to-end audio passthrough

### Phase 2: Voice Changer (RVC)

#### 2.1 RVC Setup

- [ ] Clone and install RVC repository
- [ ] Download pre-trained models
- [ ] Optimize for TensorRT inference
- [ ] Test basic voice conversion

#### 2.2 Real-time Processing

- [ ] Implement streaming audio input
- [ ] Configure RVC for real-time inference
- [ ] Optimize buffer sizes for minimum latency
- [ ] Implement voice model switching

#### 2.3 Integration

- [ ] Connect Bluetooth input to RVC
- [ ] Connect RVC output to Bluetooth speaker
- [ ] Test end-to-end voice changing
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

- [ ] Create systemd service for voice changer
- [ ] Configure auto-start on boot
- [ ] Implement graceful shutdown handling
- [ ] Add logging and monitoring

#### 4.2 Power Management

- [ ] Optimize for power efficiency
- [ ] Implement sleep/wake functionality
- [ ] Battery monitoring for peripherals (future)

#### 4.3 Testing and Refinement

- [ ] End-to-end testing with all components
- [ ] Latency measurement and optimization
- [ ] User experience testing
- [ ] Bug fixes and stability improvements

## Directory Structure (Planned)

```
jetson/
├── setup/
│   ├── install.sh          # Installation script
│   ├── bluetooth.sh         # Bluetooth configuration
│   └── audio.sh            # Audio pipeline setup
├── voice_changer/
│   ├── main.py             # Voice changer main script
│   ├── rvc_wrapper.py      # RVC interface
│   └── audio_pipeline.py   # Audio routing
├── translator/
│   ├── main.py             # Translation main script
│   ├── gemini_client.py    # Gemini Live API client
│   └── tts.py              # Text-to-speech handler
├── config/
│   ├── config.yaml         # Main configuration
│   └── voices/             # Voice model configurations
└── services/
    └── voice-changer.service # Systemd service file
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

- Jetson Orin Nano Super (8GB RAM)
- BM83 Bluetooth modules (pre-paired)
- Stable power supply

## Dependencies

### Python Packages

- `torch` (PyTorch with CUDA)
- `torchaudio`
- `numpy`
- `pydub` or `sounddevice`
- `google-cloud-aiplatform` (for Gemini)

### System Packages

- PulseAudio or PipeWire
- BlueZ (Bluetooth stack)
- CUDA Toolkit
- cuDNN
- TensorRT

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| High latency | Optimize buffer sizes, use TensorRT |
| Bluetooth instability | Implement reconnection logic |
| GPU memory constraints | Optimize model for Jetson |
| Power consumption | Use efficient inference settings |

## Success Criteria

1. Voice changing works with < 100ms latency
2. Translation mode provides usable real-time output
3. System starts automatically and runs stably
4. Bluetooth devices reconnect automatically
5. Audio quality is clear and intelligible
