import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ble_ota_app/src/ble/ble_mtu.dart';

class FlutterReactiveBleMtu extends BleMtu {
  FlutterReactiveBleMtu({required this.backend, required this.deviceId});

  final FlutterReactiveBle backend;
  final String deviceId;

  @override
  Future<int> request({required int mtu}) async {
    return await backend.requestMtu(deviceId: deviceId, mtu: mtu);
  }

  @override
  bool get isSupported => true;
}
