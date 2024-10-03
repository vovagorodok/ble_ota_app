import 'dart:async';

import 'package:bluez/bluez.dart';
import 'package:ble_ota_app/src/ble/ble_backend/ble_mtu.dart';

class BlueZMtu extends BleMtu {
  BlueZMtu({required this.device});
  final BlueZDevice device;

  @override
  Future<int> request({required int mtu}) async {
    for (BlueZGattService service in device.gattServices) {
      for (BlueZGattCharacteristic characteristic in service.characteristics) {
        int? mtu = characteristic.mtu;
        // The value provided by Bluez includes an extra 3 bytes from the GATT header, which needs to be removed.
        if (mtu != null) return mtu - 3;
      }
    }
    return mtu;
  }

  @override
  bool get isSupported => true;
}
