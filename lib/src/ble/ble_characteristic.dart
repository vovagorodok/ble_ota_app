import 'dart:async';
import 'dart:typed_data';

import 'package:ble_ota_app/src/core/data_notifier.dart';

abstract class BleCharacteristic extends DataNotifier<Uint8List> {
  Future<Uint8List> read();
  Future<void> write(Uint8List data);
  Future<void> writeWithoutResponse(Uint8List data);
  Future<void> startNotifications();
  Future<void> stopNotifications();
}
