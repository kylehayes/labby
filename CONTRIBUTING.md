# Contributing to Labby

Thank you for your interest in contributing to Labby! This document provides guidelines and information for contributors.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Documentation](#documentation)

## Code of Conduct

This project and everyone participating in it is governed by our commitment to creating a welcoming and inclusive environment. Please be respectful and constructive in all interactions.

## Getting Started

### Prerequisites

- Flutter 3.32.4 or later
- Dart 3.8.1 or later
- Git
- Platform-specific tools:
  - **macOS**: Xcode and Command Line Tools
  - **Windows**: Visual Studio with C++ support
  - **Linux**: Build essentials and development libraries

### Development Environment

1. **Fork and Clone**
   ```bash
   git clone https://github.com/kylehayes/labby.git
   cd labby
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   flutter packages pub run build_runner build
   ```

3. **Verify Setup**
   ```bash
   flutter doctor
   flutter test
   ```

## How to Contribute

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When you create a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the issue
- **Expected vs actual behavior**
- **Environment details** (OS, Flutter version, etc.)
- **Screenshots or logs** if applicable

### Suggesting Features

Feature suggestions are welcome! Please:

- Check if the feature has already been suggested
- Clearly describe the feature and its use case
- Explain why this feature would be useful
- Consider the scope and complexity

### Types of Contributions

- **Bug fixes**
- **New features**
- **Documentation improvements**
- **Performance optimizations**
- **UI/UX enhancements**
- **Testing improvements**
- **Platform-specific enhancements**

## Pull Request Process

### Before You Start

1. **Open an issue** to discuss major changes
2. **Check existing PRs** to avoid duplicates
3. **Create a feature branch** from `main`

### Development Workflow

1. **Create a Branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/bug-description
   ```

2. **Make Changes**
   - Follow our coding standards
   - Add tests for new functionality
   - Update documentation as needed

3. **Test Your Changes**
   ```bash
   flutter test
   flutter analyze
   flutter build macos/windows/linux
   ```

4. **Commit Changes**
   ```bash
   git add .
   git commit -m "feat: add new feature description"
   ```

5. **Push and Create PR**
   ```bash
   git push origin feature/your-feature-name
   ```

### PR Guidelines

- **Title**: Clear, descriptive title
- **Description**: Explain what and why
- **Link Issues**: Reference related issues
- **Screenshots**: Include UI changes
- **Testing**: Describe testing performed
- **Breaking Changes**: Document any breaking changes

## Coding Standards

### Dart/Flutter Guidelines

- Follow [Flutter style guide](https://flutter.dev/docs/development/tools/formatting)
- Use `flutter format` for code formatting
- Follow [effective Dart](https://dart.dev/guides/language/effective-dart) principles

### Code Organization

```
lib/
├── main.dart              # App entry point
├── models/               # Data models with JSON serialization
├── screens/              # UI screens and widgets
├── services/             # Business logic and API services
├── utils/                # Utility functions and helpers
└── widgets/              # Reusable custom widgets
```

### Naming Conventions

- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **Constants**: `SCREAMING_SNAKE_CASE`

### Comments and Documentation

- Document public APIs with `///` comments
- Use `//` for implementation details
- Keep comments concise and up-to-date

## Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/gitlab_api_service_test.dart

# Run tests with coverage
flutter test --coverage
```

### Writing Tests

- **Unit Tests**: For individual functions and classes
- **Widget Tests**: For UI components
- **Integration Tests**: For complete user flows

### Test Structure

```dart
// Example test structure
void main() {
  group('GitLab API Service', () {
    late GitLabApiService apiService;
    
    setUp(() {
      apiService = GitLabApiService();
    });
    
    test('should fetch projects successfully', () async {
      // Test implementation
    });
  });
}
```

## Documentation

### Types of Documentation

- **Code Comments**: Inline documentation
- **README Updates**: Installation and usage
- **API Documentation**: Service and model documentation
- **Architecture Docs**: Design decisions and patterns

### Documentation Standards

- Keep documentation up-to-date with code changes
- Use clear, concise language
- Include code examples where helpful
- Document breaking changes

## Platform-Specific Contributions

### macOS Development

- **Native Code**: Swift in `macos/Runner/`
- **Method Channels**: For Flutter-native communication
- **Status Bar**: Custom StatusBarManager implementation
- **Entitlements**: Update when adding new capabilities

### Windows Development

- **Native Code**: C++ in `windows/runner/`
- **Windows APIs**: Use appropriate Windows APIs
- **Build Configuration**: Update CMakeLists.txt as needed

### Linux Development

- **Native Code**: C++ in `linux/runner/`
- **Dependencies**: Update CMakeLists.txt for new dependencies
- **Desktop Integration**: Follow Linux desktop standards

## Release Process

### Version Management

- Follow [Semantic Versioning](https://semver.org/)
- Update version in `pubspec.yaml`
- Update changelog for releases

### Release Checklist

- [ ] All tests passing
- [ ] Documentation updated
- [ ] Version bumped
- [ ] Changelog updated
- [ ] Platform builds successful

## Getting Help

### Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Guide](https://dart.dev/guides)
- [GitLab API Documentation](https://docs.gitlab.com/ee/api/)

### Communication

- **Issues**: Use GitHub issues for bugs and features
- **Discussions**: Use GitHub discussions for questions
- **Code Review**: Be constructive and helpful in reviews

## Recognition

Contributors will be recognized in:
- README acknowledgments
- Release notes
- Git commit history

Thank you for contributing to Labby! 🎉