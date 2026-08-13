# --------------------------------------------------------------------------
# Tasker App – Makefile
# --------------------------------------------------------------------------

## Code generation (build_runner)
gen:
	flutter pub run build_runner build --delete-conflicting-outputs

icon:
	dart run flutter_launcher_icons

splash:
	dart run flutter_native_splash:create

## Build debug APK
apk-debug:
	flutter build apk --debug

## Build release APK
apk:
	flutter build apk --release

## Build release App Bundle (AAB)
appbundle:
	flutter build appbundle --release

## Install debug APK on connected device
install-debug:
	flutter install --debug

## Install release APK on connected device
install-release:
	flutter install --release
