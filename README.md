# Arduino Ble Ota App
Mobile application for upload firmware over Bluetooth.

## Setup using snap
### Android studio:
```
sudo snap install android-studio --classic
android-studio
```
In SDK manager install `Android SDK Command-line Tools`.\
And `Android Emulator`/`Android SDK Build-Tools`/`Android SDK Platform-Tools` if needed.
Create virtual device if needed.

### Flutter:
```
sudo snap install flutter --classic
flutter config --android-studio-dir /snap/android-studio/current/android-studio
flutter doctor --android-licenses
flutter doctor
```

### VS Code:
Install Flutter extension

## links
https://github.com/vovagorodok/ArduinoBleOTA
https://docs.flutter.dev/get-started/install/linux