import 'package:meta/meta.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

@immutable
class SettingsPair<T> {
  const SettingsPair({
    required this.key,
    required this.value,
  });
  final String key;
  final T value;
}

const infiniteScan = SettingsPair<bool>(
  key: 'key-infinite-scan',
  value: false,
);

const alwaysAllowLocalFileUpload = SettingsPair<bool>(
  key: 'key-allow-local-upload',
  value: false,
);

const hardwaresDictUrl = SettingsPair<String>(
  key: 'key-dict-url',
  value:
      "https://raw.githubusercontent.com/vovagorodok/ble_ota_app/main/resources/hardwares.json",
);

T getSettingsValue<T>(SettingsPair<T> pair) {
  return Settings.getValue<T>(pair.key, defaultValue: pair.value) as T;
}
