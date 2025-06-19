# Claude Code Instructions for Labby

## Project Overview
Labby is a GitLab CI/CD pipeline monitoring application built with Flutter, specifically designed for macOS with native status bar integration. The app allows users to monitor multiple GitLab projects and their pipeline statuses in real-time.

## Technology Stack
- **Framework**: Flutter (use `fvm flutter` for all commands)
- **Language**: Dart
- **Platforms**: Multi-platform with focus on macOS
- **State Management**: Provider
- **HTTP Client**: http package
- **Storage**: shared_preferences
- **Build System**: Custom Makefile + Flutter build system

## Important Commands & Build Process

### Flutter Commands
Always use `fvm flutter` instead of `flutter` directly:
```bash
fvm flutter build macos --release  # Build macOS app
fvm flutter clean                  # Clean build cache
fvm flutter pub get               # Install dependencies  
fvm flutter pub run flutter_launcher_icons  # Regenerate icons
```

### Build System
Use the Makefile for releases:
```bash
make dmg          # Build app and create DMG for distribution
make clean-dmg    # Remove DMG and staging files
make clean        # Full clean including Flutter build
```

### Release Process
1. Update version in `pubspec.yaml` 
2. Run `make dmg` to create distribution DMG
3. Commit changes and tag release: `git tag -a vX.X.X -m "Release message"`
4. Push: `git push origin main && git push origin vX.X.X`
5. Upload DMG from `releases/` directory to GitHub releases

## Project Structure
- `lib/`: Main Dart application code
  - `models/`: Data models with JSON serialization
  - `screens/`: UI screens for different app views
  - `services/`: Business logic and API services
- `assets/images/`: App icons and image assets
- `macos/`: macOS-specific native code and configurations
- `releases/`: Generated DMG files for distribution
- `Makefile`: Build automation for DMG creation

## Development Notes

### Icons & Assets
- Source icon: `assets/images/icon-512.png`
- Icons auto-generated for all platforms via `flutter_launcher_icons`
- To update icons: replace source file and run `fvm flutter pub run flutter_launcher_icons`

### macOS Specifics
- App integrates with macOS status bar
- Native entitlements configured in `macos/Runner/` 
- DMG includes drag-and-drop installer interface
- Build output: `build/macos/Build/Products/Release/Labby.app`

### Code Generation
Some models use code generation:
```bash
fvm flutter packages pub run build_runner build
```

## Testing & Quality
- Run tests: `fvm flutter test`
- Lint code: `fvm flutter analyze`
- Format code: `dart format .`

## Dependencies Management
- Keep dependencies updated but test thoroughly
- Use `fvm flutter pub outdated` to check for updates
- Update pubspec.lock after dependency changes

## Common Issues
- Always use `fvm flutter` to ensure correct Flutter version
- macOS builds may require Xcode command line tools
- DMG creation requires `create-dmg` (install via Homebrew)
- Code signing issues may require developer certificates

## Architecture Notes
- Uses Provider for state management
- HTTP service for GitLab API communication
- JSON serialization with code generation
- Reactive UI updates for pipeline status changes
- Native macOS status bar integration via platform channels