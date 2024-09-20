import 'dart:async';

import 'package:ble_ota_app/src/ble/ble_mtu.dart';

class FlutterWebBluetoothMtu extends BleMtu {
  FlutterWebBluetoothMtu();

  @override
  Future<int> request(int mtu) async {
    return mtu;
  }

  @override
  bool isSupported() => false;
}
