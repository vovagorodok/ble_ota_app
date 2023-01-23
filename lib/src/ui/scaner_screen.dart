import 'package:ble_ota_app/src/ble/ble.dart';
import 'package:ble_ota_app/src/ui/status_screen.dart';
import 'package:flutter/material.dart';
import 'package:ble_ota_app/src/ble/ble_scanner.dart';
import 'package:ble_ota_app/src/ble/ble_uuids.dart';
import 'package:ble_ota_app/src/ui/upload_screen.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class ScanerScreen extends StatefulWidget {
  const ScanerScreen({Key? key}) : super(key: key);

  @override
  State<ScanerScreen> createState() => ScanerScreenState();
}

class ScanerScreenState extends State<ScanerScreen> {
  void _evaluateBleStatus(BleStatus status) {
    setState(() {
      if (status != BleStatus.ready && status != BleStatus.unknown) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StatusScreen()),
        );
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: StreamBuilder<BleScannerState>(
            stream: bleScanner.stateStream,
            builder: (context, snapshot) => Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: ListView(
                    children: bleScanner.state.discoveredDevices
                        .map(
                          (device) => ListTile(
                            title: Text(device.name),
                            subtitle:
                                Text("${device.id}\nRSSI: ${device.rssi}"),
                            leading: const Icon(Icons.bluetooth),
                            onTap: () async {
                              bleScanner.stopScan();
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UploadScreen(
                                      deviceId: device.id,
                                      deviceName: device.name),
                                ),
                              );
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.search),
                      label: const Text('Scan'),
                      onPressed: !bleScanner.state.scanIsInProgress
                          ? () => bleScanner.startScan([serviceUuid])
                          : null,
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.search_off),
                      label: const Text('Stop'),
                      onPressed: bleScanner.state.scanIsInProgress
                          ? bleScanner.stopScan
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
