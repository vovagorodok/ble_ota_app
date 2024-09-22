import 'dart:async';

import 'package:ble_ota_app/src/ble/ble_mtu.dart';

class BlueZMtu extends BleMtu {
  @override
  Future<int> request({required int mtu}) async {
    return mtu;
  }

  @override
  bool get isSupported => false;
}
