# CLAUDE.md

This file provides guidance for Claude Code when working with this repository.

## Project Overview

This is a real-world implementation of the voice changer bowtie from Detective Conan anime. The project includes hardware designs (PCB, 3D printed cases) and software (Raspberry Pi 5 voice processing).

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

3. **Raspberry Pi 5**
   - Central processing unit
   - Runs voice changer and translation software
   - Pre-paired Bluetooth connections to mic and speaker

### Software Features (Planned)

1. **Voice Changer** - Real-time voice modification using voice-changer (Beatrice)
2. **Real-time Translation** - Japanese to English translation using Gemini Live API

## Directory Structure

```
├── 3d-models/          # 3D printable case designs (STEP format, Autodesk Fusion)
│   ├── bowtie-mic/     # Bowtie microphone case
│   └── button-speaker/ # Button speaker case
├── pcb/
│   ├── bowtie-mic/     # Microphone PCB data (EasyEDA Pro)
│   └── button-speaker/ # Speaker PCB data (EasyEDA Pro)
├── raspi5/             # Raspberry Pi 5 configuration and scripts
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

### Raspberry Pi 5 Software

- voice-changer (Beatrice) for voice conversion
- Gemini Live API for real-time translation (planned)
- PipeWire for Bluetooth audio routing

## Sponsor

3D printing for this project is sponsored by **JLCPCB**. Thank you!

## Key Commands

```bash
# See raspi5/README.md for setup instructions
```

## Important Notes

- BM83 modules need to be pre-paired with Raspberry Pi 5 for automatic connection
- Audio latency is critical for natural voice changing experience
- Power management is important for portable operation
