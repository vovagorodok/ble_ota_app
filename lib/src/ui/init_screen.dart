import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:arduino_ble_ota_app/src/ble/ble.dart';
import 'package:arduino_ble_ota_app/src/ui/scaner_screen.dart';

class InitScreen extends StatefulWidget {
  const InitScreen({Key? key}) : super(key: key);

  @override
  State<InitScreen> createState() => InitScreenState();
}

class InitScreenState extends State<InitScreen> {
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

  void _statusChanged(BleStatus status) {
    setState(() {
      if (isBleReady(status)) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ScanerScreen()),
        );
      }
    });
  }

  @override
  void initState() {
    ble.statusStream.listen(_statusChanged);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Text(_determineText(ble.status)),
        ),
      );
}
