# Fren

A tiny macOS utility for controlling ADB-connected Android devices — real hardware or emulators.

Built with SwiftUI and Liquid Glass on macOS 26.

![macOS](https://img.shields.io/badge/macOS-26%2B-blue)
![Swift](https://img.shields.io/badge/Swift-6-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## What it does

A floating Control Center-style grid that talks to your device over ADB.

**Toggles** (showing live on/off state):
- Dark mode
- Wi-Fi
- Bluetooth
- Auto-rotate
- Show taps
- Stay awake
- Do Not Disturb
- Location
- Layout bounds

**Actions:**
- Screenshot (saves PNG to Desktop)
- Open Settings
- Lock screen
- Home / Back / Recents
- Reboot

## Install

Download the latest DMG from [Releases](https://github.com/kihaki/fren/releases), or build from source:

```bash
git clone https://github.com/kihaki/fren.git
cd fren
open fren.xcodeproj
```

## Requirements

- macOS 26+
- ADB installed (e.g. via Android Studio or `brew install android-platform-tools`)
- A connected device or running emulator

## Usage

Launch the app. A phone icon appears in the menu bar. The button grid auto-detects your device and dims when nothing is connected.

Drag the handle at the top to reposition the window. Use the menu bar icon → **Recenter** if it drifts offscreen.
