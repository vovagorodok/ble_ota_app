import 'dart:io' show Platform;

import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:meta/meta.dart';

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
const skipInfoReading = Setting<bool>(
  key: 'key-skip-info-reading',
  defaultValue: false,
);
const alwaysAllowLocalFilesUpload = Setting<bool>(
  key: 'key-allow-local-upload',
  defaultValue: false,
);
final disableBuffer = Setting<bool>(
  key: 'key-disable-buffer',
  defaultValue: false,
);
final sequentialUpload = Setting<bool>(
  key: 'key-sequential-upload',
  defaultValue: _isSequentialUploadRequired,
);
const manufacturesDictUrl = Setting<String>(
  key: 'key-dict-url',
  defaultValue:
      "https://raw.githubusercontent.com/vovagorodok/ble_ota_app/main/resources/manufactures.yaml",
);
const maxMtuSize = Setting<double>(
  key: 'key-max-mtu-size',
  defaultValue: 515,
);

final _isSequentialUploadRequired =
    kIsWeb || (!Platform.isAndroid && !Platform.isIOS);
