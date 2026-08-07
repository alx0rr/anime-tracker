.PHONY: help get clean icons regen run \
        apk appbundle ios macos windows linux \
        build-all package

PROJECT := .
OUT := builds

help:
	@echo "  get        — install dependencies"
	@echo "  clean      — clean and reinstall"
	@echo "  icons      — generate app icons"
	@echo "  regen      — run build_runner"
	@echo "  run        — run debug"
	@echo "  apk        — build APK"
	@echo "  appbundle  — build AAB"
	@echo "  ios        — build iOS"
	@echo "  macos      — build macOS"
	@echo "  build-all  — build everything"
	@echo "  package    — pack artifacts"

get:
	cd $(PROJECT) && flutter pub get

clean:
	cd $(PROJECT) && flutter clean && flutter pub get

icons:
	cd $(PROJECT) && dart run flutter_launcher_icons

regen:
	cd $(PROJECT) && dart run build_runner build --delete-conflicting-outputs

run:
	cd $(PROJECT) && flutter run

run-ios:
	cd $(PROJECT) && flutter run -d iphone

run-macos:
	cd $(PROJECT) && flutter run -d macos



apk:
	@mkdir -p $(OUT)
	cd $(PROJECT) && flutter build apk --release --split-per-abi
	@cp -f $(PROJECT)/build/app/outputs/flutter-apk/*.apk $(OUT)/ 2>/dev/null || true

apk-universal:
	@mkdir -p $(OUT)
	cd $(PROJECT) && flutter build apk --release
	@cp -f $(PROJECT)/build/app/outputs/flutter-apk/app-release.apk $(OUT)/app-universal-release.apk 2>/dev/null || true

apk-all: apk-universal
	@mkdir -p $(OUT)
	cd $(PROJECT) && flutter build apk --release --split-per-abi
	@cp -f $(PROJECT)/build/app/outputs/flutter-apk/*.apk $(OUT)/ 2>/dev/null || true



appbundle:
	@mkdir -p $(OUT)
	cd $(PROJECT) && flutter build appbundle --release
	@cp -f $(PROJECT)/build/app/outputs/bundle/release/*.aab $(OUT)/ 2>/dev/null || true

ios:
	@mkdir -p $(OUT)/ios
	cd $(PROJECT) && flutter build ios --release --no-codesign
	@cp -r $(PROJECT)/build/ios/iphoneos/Runner.app $(OUT)/ios/ 2>/dev/null || true

macos:
	@mkdir -p $(OUT)
	cd $(PROJECT) && flutter build macos --release
	@cp -r $(PROJECT)/build/macos/Build/Products/Release/*.app $(OUT)/ 2>/dev/null || true

windows:
	@mkdir -p $(OUT)
	cd $(PROJECT) && flutter build windows --release
	@cp -r $(PROJECT)/build/windows/x64/runner/Release $(OUT)/windows 2>/dev/null || true

linux:
	@mkdir -p $(OUT)
	cd $(PROJECT) && flutter build linux --release
	@cp -r $(PROJECT)/build/linux/x64/release/bundle $(OUT)/linux 2>/dev/null || true

build-all: icons regen apk appbundle ios macos

package:
	@mkdir -p $(OUT)
	@tar -czf $(OUT)/artifacts.tar.gz -C $(OUT) . 2>/dev/null || true



ipa:
	@mkdir -p $(OUT)
	cd $(PROJECT) && flutter build ios --release --no-codesign
	@rm -rf $(PROJECT)/build/ios/ipa_tmp
	@mkdir -p $(PROJECT)/build/ios/ipa_tmp/Payload
	@cp -r $(PROJECT)/build/ios/iphoneos/Runner.app $(PROJECT)/build/ios/ipa_tmp/Payload/
	cd $(PROJECT)/build/ios/ipa_tmp && zip -r -q Runner.ipa Payload
	@cp -f $(PROJECT)/build/ios/ipa_tmp/Runner.ipa $(OUT)/app-release.ipa
	@rm -rf $(PROJECT)/build/ios/ipa_tmp