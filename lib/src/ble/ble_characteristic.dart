import 'dart:async';

import 'package:ble_ota_app/src/core/data_notifier.dart';

abstract class BleCharacteristic extends DataNotifier<List<int>> {
  Future<List<int>> read();
  Future<void> write(List<int> data);
  Future<void> writeWithoutResponse(List<int> data);
  Future<void> startNotifications();
  Future<void> stopNotifications();
}
