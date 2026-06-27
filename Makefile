# --------------------------------------------------------------------------
# Tasker App – Makefile
# --------------------------------------------------------------------------

## Code generation (build_runner)
gen:
	flutter pub run build_runner build --delete-conflicting-outputs

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
