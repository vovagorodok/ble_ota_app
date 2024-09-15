import 'dart:async';

import 'package:universal_ble/universal_ble.dart';
import 'package:ble_ota_app/src/ble/ble_mtu.dart';

class UniversalBleMtu extends BleMtu {
  UniversalBleMtu({required this.deviceId});

  final String deviceId;

  @override
  Future<int> request(int mtu) async {
    return await UniversalBle.requestMtu(deviceId, mtu);
  }
}
