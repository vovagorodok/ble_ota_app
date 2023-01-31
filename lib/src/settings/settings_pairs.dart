import 'package:flutter_settings_screens/flutter_settings_screens.dart';

const keyInfiniteScan = 'key-infinite-scan';
const valueInfiniteScan = false;

const keyAlwaysAllowLocalFileUpload = 'key-allow-local-upload';
const valueAlwaysAllowLocalFileUpload = false;

const keyHardwaresDictUrl = 'key-dict-url';
const valueHardwaresDictUrl =
    "https://raw.githubusercontent.com/vovagorodok/ble_ota_app/main/resources/hardwares.json";

T getSettingsValue<T>(String key, T defaultValue) {
  return Settings.getValue<T>(key, defaultValue: defaultValue) as T;
}
