import 'dart:async';

import 'package:ble_ota_app/src/ble/ble_backend/ble_mtu.dart';

class FlutterWebBluetoothMtu extends BleMtu {
  FlutterWebBluetoothMtu();

  @override
  Future<int> request({required int mtu}) async {
    return mtu;
  }

  @override
  bool get isSupported => false;
}
