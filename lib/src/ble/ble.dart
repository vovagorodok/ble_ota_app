import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:ble_ota_app/src/ble/ble_central.dart';
import 'package:ble_ota_app/src/ble/flutter_reactive_ble_central.dart';
import 'package:ble_ota_app/src/ble/flutter_web_bluetooth_central.dart';
import 'package:ble_ota_app/src/ble/universal_ble_central.dart';
import 'package:ble_ota_app/src/ble/bluetooth_low_energy_central.dart';

BleCentral createCentral() {
  if (kIsWeb) {
    return FlutterWebBluetoothCentral();
  } else if (Platform.isAndroid || Platform.isIOS) {
    return FlutterReactiveBleCentral(backend: FlutterReactiveBle());
  } else if (Platform.isWindows) {
    return UniversalBleCentral();
  } else {
    return BluetoothLowEnergyCentral(backend: CentralManager());
  }
}

final isSequentialUploadRequiredByBleLibrary =
    !kIsWeb && !Platform.isAndroid && !Platform.isIOS;

final bleCentral = createCentral();
