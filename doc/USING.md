# Using guide

## Web
Bluetooth support is experimental for web and can be enabled at `chrome://flags`.  
Run flutter with experimental flags:
```
flutter run -d chrome --release --web-browser-flag "--enable-experimental-web-platform-features" --web-browser-flag "--disable-web-security"
```