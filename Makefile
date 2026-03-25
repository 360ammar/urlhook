SWIFT_FILES = swift/urlhook/main.swift \
              swift/urlhook/AppDelegate.swift \
              swift/urlhook/SocketClient.swift

APP_NAME = urlhook
APP_BUNDLE = macos/$(APP_NAME).app
CONTENTS = $(APP_BUNDLE)/Contents
MACOS_DIR = $(CONTENTS)/MacOS

.PHONY: build clean

build: $(APP_BUNDLE)

$(APP_BUNDLE): $(SWIFT_FILES) swift/urlhook/Info.plist
	@mkdir -p $(MACOS_DIR)
	swiftc $(SWIFT_FILES) \
		-o $(MACOS_DIR)/$(APP_NAME) \
		-target arm64-apple-macos13 \
		-framework Cocoa \
		-O
	cp swift/urlhook/Info.plist $(CONTENTS)/Info.plist
	@echo "Built $(APP_BUNDLE)"

clean:
	rm -rf $(APP_BUNDLE)
