import 'package:meta/meta.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

@immutable
class Setting<T> {
  const Setting({
    required this.key,
    required this.defaultValue,
  });

  T get value => Settings.getValue<T>(key, defaultValue: defaultValue) as T;

  final String key;
  final T defaultValue;
}

const infiniteScan = Setting<bool>(
  key: 'key-infinite-scan',
  defaultValue: false,
);
const alwaysAllowLocalFileUpload = Setting<bool>(
  key: 'key-allow-local-upload',
  defaultValue: false,
);
const hardwaresDictUrl = Setting<String>(
  key: 'key-dict-url',
  defaultValue:
      "https://raw.githubusercontent.com/vovagorodok/ble_ota_app/main/resources/hardwares.json",
);
