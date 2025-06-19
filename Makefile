.PHONY: dmg clean-dmg build-macos

# Variables
APP_NAME = Labby
VERSION = 1.0.0
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
	@echo "Building macOS app..."
	@fvm flutter build macos --release

clean-dmg:
	@echo "Cleaning previous DMG..."
	@rm -f "$(RELEASES_DIR)/$(DMG_NAME)"
	@rm -rf $(STAGING_DIR)

clean: clean-dmg
	@echo "Cleaning Flutter build..."
	@fvm flutter clean