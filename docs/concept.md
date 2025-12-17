# Project Concept

## Vision

Bring the iconic voice changer bowtie from Detective Conan anime to reality. This device allows the user to speak into a bowtie-shaped microphone and have their transformed voice emitted from a button-shaped speaker placed elsewhere.

## Inspiration

In the Detective Conan manga and anime series, the protagonist uses a "bowtie voice changer" invented by Dr. Agasa. The device allows him to mimic any voice by speaking into a bowtie-shaped microphone, with the modified voice coming out of a speaker placed near the target.

This project aims to create a functional real-world version of this fictional device.

## System Architecture

```
┌─────────────────────┐     Bluetooth HFP     ┌──────────────────────┐
│   Bowtie Mic        │◄────────────────────►│                      │
│   - BM83 Module     │                       │   Jetson Orin Nano   │
│   - MEMS Microphone │                       │        Super         │
│   - Battery         │                       │                      │
│   - 3D Printed Case │                       │   - Voice Changer    │
└─────────────────────┘                       │     (RVC)            │
                                              │                      │
┌─────────────────────┐     Bluetooth A2DP    │   - Real-time        │
│   Button Speaker    │◄────────────────────►│     Translation      │
│   - BM83 Module     │                       │     (Gemini Live)    │
│   - Thin Speaker    │                       │                      │
│   - Battery         │                       └──────────────────────┘
│   - 3D Printed Case │
└─────────────────────┘
```

## Hardware Design Philosophy

### Bowtie Microphone

- **Form Factor**: Classic bowtie shape to match the original anime design
- **Wireless**: Bluetooth HFP profile for bidirectional audio
- **Portable**: Battery-powered for wearable use
- **Audio Quality**: MEMS microphone for clear voice capture

### Button Speaker

- **Discreet**: Small button shape that can be hidden or placed strategically
- **High Quality Output**: Thin but capable speaker for clear voice reproduction
- **Wireless**: Bluetooth A2DP profile for high-quality audio streaming
- **Portable**: Battery-powered for flexible placement

### Why BM83?

The Microchip BM83 Bluetooth module was chosen for:
- Dual-mode Bluetooth (Classic + BLE)
- Support for HFP and A2DP profiles
- Low power consumption
- Compact form factor
- Built-in audio codec

## Software Features

### Voice Changer (RVC)

RVC (Retrieval-based Voice Conversion) enables real-time voice transformation:
- Train on target voice samples
- Real-time inference on Jetson GPU
- Low latency processing for natural conversation

### Real-time Translation (Gemini Live API)

Japanese to English translation using Google's Gemini Live API:
- Speech-to-text in Japanese
- Real-time translation
- Text-to-speech in English (with voice changer applied)

## Use Cases

1. **Cosplay**: Authentic Detective Conan cosplay with functional props
2. **Entertainment**: Fun voice changing for parties and events
3. **Accessibility**: Potential applications for speech assistance
4. **Translation**: Real-time Japanese to English interpretation

## Challenges

1. **Latency**: Minimizing delay between input and output for natural feel
2. **Audio Quality**: Balancing compact design with good sound quality
3. **Battery Life**: Optimizing power consumption for extended use
4. **Bluetooth Stability**: Ensuring reliable connection between devices

## Future Enhancements

- Multiple voice presets
- Mobile app for control and configuration
- Two-way translation support
- Voice cloning from short samples
- Improved battery life and charging solutions
