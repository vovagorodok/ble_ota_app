import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ble_ota_app/src/ble/flutter_reactive_ble_central.dart';
import 'package:ble_ota_app/src/ble/flutter_web_bluetooth_central.dart';

final bleCentral = kIsWeb
    ? FlutterWebBluetoothCentral()
    : FlutterReactiveBleCentral(backend: FlutterReactiveBle());
