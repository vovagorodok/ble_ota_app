import 'package:flutter/material.dart';
import 'package:arduino_ble_ota_app/src/ble/ble.dart';
import 'package:arduino_ble_ota_app/src/ui/init_screen.dart';
import 'package:arduino_ble_ota_app/src/ui/scaner_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arduino BLE OTA',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: isBleReady(ble.status) ? const ScanerScreen() : const InitScreen(),
    );
  }
}
