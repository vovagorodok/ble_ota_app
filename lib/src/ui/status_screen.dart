import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:arduino_ble_ota_app/src/ble/ble.dart';
import 'package:permission_handler/permission_handler.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({Key? key}) : super(key: key);

  @override
  State<StatusScreen> createState() => StatusScreenState();
}

class StatusScreenState extends State<StatusScreen> {
  String _determineText(BleStatus status) {
    switch (status) {
      case BleStatus.unsupported:
        return "This device does not support Bluetooth";
      case BleStatus.unauthorized:
        return "Authorize applicatin to use Bluetooth and location";
      case BleStatus.poweredOff:
        return "Bluetooth is powered off on your device turn it on";
      case BleStatus.locationServicesDisabled:
        return "Enable location services";
      case BleStatus.ready:
        return "Bluetooth is up and running";
      default:
        return "Waiting to fetch Bluetooth status $status";
    }
  }

  void _evaluateBleStatus(BleStatus status) {
    setState(() {
      if (status == BleStatus.ready) {
        Navigator.pop(context);
      } else if (status == BleStatus.unauthorized) {
        if (Platform.isAndroid) {
          Permission.location.request();
        }
      }
    });
  }

  @override
  void initState() {
    ble.statusStream.listen(_evaluateBleStatus);
    _evaluateBleStatus(ble.status);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Center(
              child: Text(
                _determineText(ble.status),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 30.0),
              ),
            ),
          ),
        ),
      );
}
