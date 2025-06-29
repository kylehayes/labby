.PHONY: dmg clean-dmg build-macos test test-coverage test-models test-services test-widgets lint format codegen help

# Variables
APP_NAME = Labby
VERSION = $(shell grep '^version:' pubspec.yaml | cut -d' ' -f2 | cut -d'+' -f1)
DMG_NAME = $(APP_NAME)-$(VERSION).dmg
BUILD_DIR = build/macos/Build/Products/Release
STAGING_DIR = dmg-staging
RELEASES_DIR = releases

dmg: clean-dmg build-macos
	@echo "Creating DMG staging directory..."
	@mkdir -p $(STAGING_DIR)
	@cp -R "$(BUILD_DIR)/$(APP_NAME).app" "$(STAGING_DIR)/"
	@echo "Creating DMG..."
	@create-dmg \
		--volname "$(APP_NAME)" \
		--window-pos 200 120 \
		--window-size 600 300 \
		--icon-size 100 \
		--icon "$(APP_NAME).app" 175 120 \
		--hide-extension "$(APP_NAME).app" \
		--app-drop-link 425 120 \
		"$(RELEASES_DIR)/$(DMG_NAME)" \
		"$(STAGING_DIR)/"
	@echo "DMG created: $(RELEASES_DIR)/$(DMG_NAME)"
	@rm -rf $(STAGING_DIR)

build-macos:
	@echo "Building macOS app (version $(VERSION))..."
	@fvm flutter build macos --release --build-name=$(VERSION)

clean-dmg:
	@echo "Cleaning previous DMG..."
	@rm -f "$(RELEASES_DIR)/$(DMG_NAME)"
	@rm -rf $(STAGING_DIR)

clean: clean-dmg
	@echo "Cleaning Flutter build..."
	@fvm flutter clean

# Testing targets
test:
	@echo "Running all tests..."
	@fvm flutter test

test-coverage:
	@echo "Running tests with coverage..."
	@fvm flutter test --coverage
	@echo "Coverage report generated in coverage/lcov.info"

test-models:
	@echo "Running model tests..."
	@fvm flutter test test/models/

test-services:
	@echo "Running service tests..."
	@fvm flutter test test/services/

test-widgets:
	@echo "Running widget tests..."
	@fvm flutter test test/widget_test.dart

# Code quality targets
lint:
	@echo "Analyzing code..."
	@fvm flutter analyze

format:
	@echo "Formatting code..."
	@dart format .

format-check:
	@echo "Checking code formatting..."
	@dart format --output=none --set-exit-if-changed .

codegen:
	@echo "Generating code..."
	@fvm flutter packages pub run build_runner build --delete-conflicting-outputs

# Combined targets
check: format-check lint test
	@echo "All checks passed! ✅"

ci: codegen check
	@echo "CI checks completed! 🚀"

help:
	@echo "Available targets:"
	@echo "  dmg           - Build macOS DMG for distribution"
	@echo "  build-macos   - Build macOS app"
	@echo "  clean         - Clean build artifacts"
	@echo ""
	@echo "Testing:"
	@echo "  test          - Run all tests"
	@echo "  test-coverage - Run tests with coverage report"
	@echo "  test-models   - Run only model tests"
	@echo "  test-services - Run only service tests"
	@echo "  test-widgets  - Run only widget tests"
	@echo ""
	@echo "Code Quality:"
	@echo "  lint          - Analyze code for issues"
	@echo "  format        - Format code"
	@echo "  format-check  - Check if code is properly formatted"
	@echo "  codegen       - Generate model serialization code"
	@echo ""
	@echo "Combined:"
	@echo "  check         - Run format check, lint, and tests"
	@echo "  ci            - Run full CI pipeline (codegen + check)"
	@echo "  help          - Show this help message"