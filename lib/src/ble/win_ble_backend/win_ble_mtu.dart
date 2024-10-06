import 'dart:async';
import 'dart:math';

import 'package:win_ble/win_ble.dart';
import 'package:ble_ota_app/src/ble/ble_backend/ble_mtu.dart';

class WinBleMtu extends BleMtu {
  WinBleMtu({required this.deviceId});

  final String deviceId;

  @override
  Future<int> request({required int mtu}) async {
    return min(await WinBle.getMaxMtuSize(deviceId), mtu);
  }

  @override
  bool get isRequestSupported => true;
}
