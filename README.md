# Labby

A cross-platform GitLab CI/CD pipeline monitoring application with real-time status updates and native macOS status bar integration.

![Platform Support](https://img.shields.io/badge/platform-macOS%20%7C%20Windows%20%7C%20Linux-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.32.4-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## Features

- **Real-time Pipeline Monitoring** - Track pipeline status from your GitLab projedcts
- **Native macOS Status Bar** - Color-coded status indicator in your menu bar
- **Detailed Pipeline View** - See individual job statuses and execution times
- **Start manual jobs** - Trigger manual jobs without leaving Labby
- **Auto-refresh** - Automatically updates pipeline status at configurable intervals
- **Dark/Light Theme** - Supports system theme preferences
- **Cross-Platform** - Runs on macOS, Windows, and Linux

### Main Interface
- Project list with pipeline status overview
- Pipeline detail view with job breakdown
- Configuration screen for GitLab API setup

### macOS Status Bar Integration
- 🟢 Green: All pipelines successful
- 🔴 Red: One or more pipelines failed
- 🔵 Blue: Pipelines currently running
- 🟠 Orange: Manual jobs available to start
- ⚫ Gray: Unknown or no active monitoring

## Prerequisites

- Flutter 3.32.4 or later
- GitLab account with API access
- GitLab Personal Access Token with `api` scope

## Installation

### Option 1: Download Pre-built Releases (Coming Soon)
Check the [Releases](../../releases) page for pre-built binaries.

### Option 2: Build from Source

1. **Clone the repository:**
   ```bash
   git clone https://github.com/kylehayes/labby.git
   cd labby
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate model files:**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the application:**
   ```bash
   # For macOS
   flutter run -d macos
   
   # For Windows
   flutter run -d windows
   
   # For Linux
   flutter run -d linux
   ```

## Configuration

1. **Get your GitLab Personal Access Token:**
   - Go to GitLab → Settings → Access Tokens
   - Create a new token with `read_api` scope
   - Copy the generated token

2. **Configure the application:**
   - Launch the app
   - Enter your GitLab instance URL (e.g., `https://gitlab.com`)
   - Paste your Personal Access Token
   - Save the configuration

3. **Add projects to monitor:**
   - Browse and select GitLab projects
   - View pipeline statuses and details

## Development

### Prerequisites for Development
- Flutter SDK 3.32.4+
- Dart SDK 3.8.1+
- Xcode (for macOS builds)
- Visual Studio (for Windows builds)
- Linux development tools (for Linux builds)

### Project Structure
```
lib/
├── main.dart              # App entry point
├── models/               # Data models (GitLab API responses)
├── screens/              # UI screens
├── services/             # API and platform services
└── ...

macos/Runner/             # macOS-specific code
├── AppDelegate.swift     # Method channel setup
├── StatusBarManager.swift # Status bar implementation
└── ...
```

### Building for Production

```bash
# macOS
flutter build macos --release

# Windows
flutter build windows --release

# Linux
flutter build linux --release
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Setup
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests if applicable
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Code Style
- Follow Flutter/Dart conventions
- Use meaningful variable and function names
- Add comments for complex logic
- Ensure all tests pass

## Troubleshooting

### Common Issues

**Status bar not appearing on macOS:**
- Ensure you've granted necessary permissions
- Check console output for initialization errors

**API connection issues:**
- Verify your GitLab URL and access token
- Check network connectivity
- Ensure token has `read_api` scope

**Build issues:**
- Run `flutter clean && flutter pub get`
- Regenerate models: `flutter packages pub run build_runner build --delete-conflicting-outputs`

### Debug Mode
The app includes debug logging. Check console output for detailed information about API calls and status updates.

## Roadmap

- [ ] GitHub Actions/CI integration
- [ ] Notification system for pipeline events
- [ ] Pipeline retry functionality
- [ ] Multiple GitLab instance support
- [ ] Mobile app versions (iOS/Android)
- [ ] Custom notification sounds
- [ ] Pipeline history and analytics

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with [Flutter](https://flutter.dev/)
- Uses [GitLab API](https://docs.gitlab.com/ee/api/) for pipeline data
- Icons and UI components from Flutter's Material Design

## Support

If you encounter any issues or have questions:
1. Check the [Issues](../../issues) page
2. Create a new issue with detailed information
3. Include logs and system information when reporting bugs

---

Made with ❤️ using Flutter
