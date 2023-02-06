import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ble_ota_app/src/ble/ble.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => StatusScreenState();
}

class StatusScreenState extends State<StatusScreen> {
  String _determineText(BleStatus status) {
    switch (status) {
      case BleStatus.unsupported:
        return tr('ThisDeviceDoesNotSupportBluetooth');
      case BleStatus.unauthorized:
        return tr('AuthorizeApplicationToUseBluetoothAndLocation');
      case BleStatus.poweredOff:
        return tr('BluetoothIsDisabledTurnItOn');
      case BleStatus.locationServicesDisabled:
        return tr('LocationServicesAreDisabledEnableThem');
      case BleStatus.ready:
        return tr('BluetoothIsUpAndRunning');
      default:
        return tr('WaitingToFetchBluetoothStatus', args: ['$status']);
    }
  }

  void _evaluateBleStatus(BleStatus status) {
    setState(() {
      if (status == BleStatus.ready) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    ble.statusStream.listen(_evaluateBleStatus);
    () async {
      if (Platform.isAndroid) {
        await Permission.location.request();
      }
      await Permission.bluetooth.request();
      await Permission.bluetoothScan.request();
      await Permission.bluetoothAdvertise.request();
    }.call();
    _evaluateBleStatus(ble.status);
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Center(
                child: Text(
                  _determineText(ble.status),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
