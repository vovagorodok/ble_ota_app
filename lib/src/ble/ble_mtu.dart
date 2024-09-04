import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleMtu {
  BleMtu({required this.backend, required this.deviceId});

  final FlutterReactiveBle backend;
  final String deviceId;

  Future<int> request(int mtu) async {
    return await backend.requestMtu(deviceId: deviceId, mtu: mtu);
  }
}
