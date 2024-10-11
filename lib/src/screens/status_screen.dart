import 'dart:io';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:ble_backend/ble_central.dart';
import 'package:ble_backend_factory/ble_central.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => StatusScreenState();
}

class StatusScreenState extends State<StatusScreen> {
  String _determineText(BleCentralStatus status) {
    switch (status) {
      case BleCentralStatus.unsupported:
        return tr('ThisDeviceDoesNotSupportBluetooth');
      case BleCentralStatus.unsupportedBrowser:
        return tr('ThisBrowserDoesNotSupportBluetooth');
      case BleCentralStatus.unauthorized:
        return tr('AuthorizeApplicationToUseBluetoothAndLocation');
      case BleCentralStatus.poweredOff:
        return tr('BluetoothIsDisabledTurnItOn');
      case BleCentralStatus.locationServicesDisabled:
        return tr('LocationServicesAreDisabledEnableThem');
      case BleCentralStatus.ready:
        return tr('BluetoothIsUpAndRunning');
      default:
        return tr('WaitingToFetchBluetoothStatus', args: ['$status']);
    }
  }

  IconData _determineIcon(BleCentralStatus status) {
    switch (status) {
      case BleCentralStatus.unsupported:
        return Icons.bluetooth_disabled_rounded;
      case BleCentralStatus.unsupportedBrowser:
        return Icons.browser_not_supported_rounded;
      case BleCentralStatus.unauthorized:
        return Icons.person_off_rounded;
      case BleCentralStatus.poweredOff:
        return Icons.bluetooth_disabled_rounded;
      case BleCentralStatus.locationServicesDisabled:
        return Icons.location_off_rounded;
      case BleCentralStatus.ready:
        return Icons.bluetooth_rounded;
      default:
        return Icons.autorenew_rounded;
    }
  }

  void _evaluateBleCentralStatus(BleCentralStatus status) {
    setState(() {
      if (status == BleCentralStatus.ready) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    bleCentral.stateStream.listen(_evaluateBleCentralStatus);
    () async {
      if (!Platform.isAndroid && !Platform.isIOS && !Platform.isWindows) return;

      if (Platform.isAndroid) {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        final sdkVersion = androidInfo.version.sdkInt;
        if (sdkVersion < 31) {
          await Permission.location.request();
        }
      }
      await Permission.bluetooth.request();
      await Permission.bluetoothScan.request();
      await Permission.bluetoothAdvertise.request();
      await Permission.bluetoothConnect.request();
    }.call();
    _evaluateBleCentralStatus(bleCentral.state);
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        child: Scaffold(
          body: SafeArea(
            minimum: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _determineText(bleCentral.state),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0,
                  ),
                ),
                const SizedBox(height: 20),
                Icon(
                  _determineIcon(bleCentral.state),
                  size: 100,
                ),
              ],
            ),
          ),
        ),
      );
}
