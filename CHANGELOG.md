# Changelog

All notable changes to FrameBoost will be documented in this file.

## [1.0.0] - 2024-01-01

### Added
- Real-time FPS overlay with configurable position and style
- Frametime display in milliseconds
- Stutter detection with user-configurable threshold
- Session statistics: average / minimum / maximum FPS
- P95 frametime calculation
- Per-app game profiles via bundle ID allowlist
- Three performance profiles: Battery, Balanced, Stability
- Stutter event log with ring buffer (512 events)
- Log export to /var/mobile/Documents/frameboost_stutter.log
- Full Settings.app preference bundle with 6 sections
- Darwin notify for live preference reload without respring
- Dopamine rootless compatibility (arm64 + arm64e)
