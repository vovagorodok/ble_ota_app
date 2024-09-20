import 'dart:async';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:ble_ota_app/src/ble/ble_mtu.dart';

class BluetoothLowEnergyMtu extends BleMtu {
  BluetoothLowEnergyMtu({required this.backend, required this.peripheral});

  final CentralManager backend;
  final Peripheral peripheral;

  @override
  Future<int> request(int mtu) async {
    return await backend.requestMTU(peripheral, mtu: mtu);
  }

  @override
  bool get isSupported => true;
}
