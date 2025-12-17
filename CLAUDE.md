# CLAUDE.md

This file provides guidance for Claude Code when working with this repository.

## Project Overview

This is a real-world implementation of the voice changer bowtie from Detective Conan anime. The project includes hardware designs (PCB, 3D printed cases) and software (Jetson Orin Nano Super voice processing).

## Architecture

### Hardware Components

1. **Bowtie Microphone**
   - BM83 Bluetooth module with MEMS microphone
   - Custom PCB (EasyEDA Pro design)
   - 3D printed case (Autodesk Fusion)
   - Battery powered
   - Bluetooth HFP profile for audio transmission

2. **Button Speaker**
   - BM83 Bluetooth module with thin speaker
   - Custom PCB (EasyEDA Pro design)
   - 3D printed case (Autodesk Fusion)
   - Battery powered
   - Bluetooth A2DP profile for audio reception

3. **Jetson Orin Nano Super**
   - Central processing unit
   - Runs voice changer and translation software
   - Pre-paired Bluetooth connections to mic and speaker

### Software Features (Planned)

1. **Voice Changer** - Real-time voice modification using RVC (Retrieval-based Voice Conversion)
2. **Real-time Translation** - Japanese to English translation using Gemini Live API

## Directory Structure

```
├── 3d-models/          # 3D printable case designs (STEP format, Autodesk Fusion)
├── pcb/
│   ├── bowtie-mic/     # Microphone PCB data (EasyEDA Pro)
│   └── button-speaker/ # Speaker PCB data (EasyEDA Pro)
├── jetson/             # (Planned) Jetson configuration and scripts
├── docs/               # Documentation
└── screen-records/     # Development recordings (gitignored)
```

## Development Guidelines

### Language

- All documentation and code comments: **English**
- Conversation with users: May use Japanese if requested

### PCB Design

- Use EasyEDA Pro for schematic and PCB design
- Export Gerber, BOM, and Pick-and-Place files for JLCPCB manufacturing
- Include 3D STEP models for verification

### 3D Modeling

- Use Autodesk Fusion for case design
- Export as STEP format
- Consider component clearance and assembly

### Jetson Software

- Python-based audio processing
- RVC for voice conversion
- Gemini Live API for real-time translation
- PulseAudio/PipeWire for Bluetooth audio routing

## Sponsor

3D printing for this project is sponsored by **JLCPCB**. Thank you!

## Key Commands

```bash
# No build commands yet - Jetson software implementation pending
```

## Important Notes

- BM83 modules need to be pre-paired with Jetson for automatic connection
- Audio latency is critical for natural voice changing experience
- Power management is important for portable operation
