# FrameBoost

Author: bluexdeev25432

![Version](https://img.shields.io/badge/Version-1.0.0-00FF88?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-iOS%2015%20%E2%80%93%2016-0066FF?style=flat-square)
![Jailbreak](https://img.shields.io/badge/Jailbreak-Dopamine%20rootless-00C853?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-FFB000?style=flat-square)
![Build](https://github.com/bluexdeev25432/FrameBoost/actions/workflows/release.yml/badge.svg)

## What is FrameBoost?

FrameBoost is a real-time FPS overlay and frame diagnostic tweak for iOS 15 and 16, designed for the Dopamine rootless jailbreak. It measures display cadence via CADisplayLink callbacks so you can monitor smoothness and stutter without altering hardware behavior. This is intentionally not a direct GPU render-time profiler, and it does not manipulate CPU, GPU, or display clocks. It is a monitoring utility meant to help diagnose performance and frame pacing in real time.

## Features

- 📊 Real-time FPS overlay
- ⏱ Frametime display in milliseconds
- 📉 Stutter detection with configurable threshold
- 📈 Session statistics: avg / min / max FPS, P95 frametime
- 🌡 Thermal state indicator (Battery / Fair / Serious / Critical)
- 💾 RAM usage display
- 🎮 Per-app game profiles (inject only into allowed apps)
- ⚡ Three performance profiles: Battery / Balanced / Stability
- 📋 Stutter log export to /var/mobile/Documents/
- 🔧 Full Settings.app preference bundle

## Screenshots

![FPS Overlay](docs/screenshots/overlay.png)
![Settings](docs/screenshots/settings.png)
![Stutter Log](docs/screenshots/stutter.png)

Screenshots taken on iPhone running iOS 15.7 with Dopamine jailbreak.

## Requirements

- iOS 15.0 – 16.7
- Dopamine jailbreak (rootless)
- ElleKit or libhooker
- PreferenceLoader 2.2.4+
- Sileo or Zebra package manager

## Installation via Sileo

1. Open Sileo
2. Go to the Sources tab and tap Edit → Add
3. Enter the repo URL: https://bluexdeev25432.github.io/FrameBoost/repo/
4. Search for FrameBoost and install it
5. Respring when prompted
6. Open Settings → FrameBoost to configure

## Installation via .deb (manual)

1. Download the latest .deb from GitHub Releases
2. Copy it to the device: scp frameboost.deb mobile@192.168.1.10:/var/mobile/Documents/
3. In Sileo, tap + → Local .deb → select the file → Install
4. Respring

## Configuration

| Key | Type | Default | Description |
|---|---|---:|---|
| enabled | BOOL | YES | Enables or disables the tweak globally |
| overlayEnabled | BOOL | YES | Shows or hides the FPS overlay |
| updateInterval | Double | 0.5 | Refresh interval in seconds for stats updates |
| stutterThresholdMS | Double | 33.3 | Frametime threshold before logging a stutter |
| overlayX | Double | 8.0 | Overlay horizontal position |
| overlayY | Double | 60.0 | Overlay vertical position |
| fontSize | Double | 12.0 | Overlay text size |
| bgAlpha | Double | 0.55 | Overlay background opacity |
| showFrametime | BOOL | YES | Displays frametime beneath FPS |
| perfProfile | Integer | 1 | 0 = Battery, 1 = Balanced, 2 = Stability |
| allowedBundleIDs | Array | empty | Restricts monitoring to selected bundle IDs |
| textColorHex | String | #00FF88 | Accent color for the overlay |

## Adding a Game Profile

1. Open Settings → FrameBoost → Game Profiles
2. Add the game's Bundle ID (find it in Filza under /var/containers/Bundle/Application/)
3. Toggle monitoring on for that app
4. Relaunch the game

## Measurement Accuracy Note

FPS values in FrameBoost are derived from the CADisplayLink callback interval, which represents vsync cadence rather than direct GPU scanout timing. On ProMotion devices, this means the reported FPS can vary naturally with the active system refresh rate. The result is a useful monitoring proxy for responsiveness and pacing, not a hardware-accurate performance counter or GPU render latency metric.

## Building from Source

```bash
# Prerequisites
brew install ldid dpkg
git clone https://github.com/theos/theos ~/theos
export THEOS=~/theos

# Clone and build
git clone https://github.com/bluexdeev25432/FrameBoost
cd FrameBoost
make clean
make package FINALPACKAGE=1

# Output
ls packages/*.deb
```

## Troubleshooting

| Problem | Cause | Fix |
|---|---|---|
| FrameBoost not in Settings | PreferenceLoader not installed | Install PreferenceLoader from Chariz repo |
| Overlay not showing | App not in allowed list | Add bundle ID in Game Profiles |
| Overlay not showing | overlayEnabled is OFF | Enable in Settings → FrameBoost → General |
| Settings crash | Prefs bundle not loaded | Run: plutil -lint on entry.plist via SSH |
| FPS shows 0 | App went to background | Bring app to the foreground |
| Build fails: command not found | Theos not installed | Follow theos.dev/docs/install |
| Build fails: arm64e unsigned | ldid not in PATH | brew install ldid |
| deb missing from packages | GitHub Actions not triggered | Push a tag: git tag 1.0.0 && git push --tags |

## Uninstall

```bash
# Via Sileo: tap FrameBoost → Remove → Respring

# Manual via SSH:
rm /var/jb/Library/MobileSubstrate/DynamicLibraries/FrameBoost.*
rm -rf /var/jb/Library/PreferenceBundles/FrameBoostPrefs.bundle
rm -rf /var/jb/Library/PreferenceLoader/Preferences/FrameBoost
defaults delete com.bluexdeev25432.frameboost
sbreload
```

## License

MIT — see LICENSE file.

## Credits

- Theos build system: theos.dev
- ElleKit: elihwyma
- Dopamine: opa334
