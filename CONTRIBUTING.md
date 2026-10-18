# Contributing

Thanks for helping improve QRaksha.

## Before opening a pull request
1. Keep URL analysis local by default.
2. Do not automatically open scanned URLs.
3. Add or update tests for new URL rules.
4. Describe false-positive risks for any new heuristic.
5. Do not claim that a low score means a URL is safe.
6. Avoid sending scanned URLs to third-party services without explicit user consent.

## Development
Open `QRaksha.xcodeproj` in Xcode on macOS. Build and run the app, run the unit tests, and test camera scanning on a physical iPhone before merging camera-related changes.
