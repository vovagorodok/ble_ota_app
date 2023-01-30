import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:wakelock/wakelock.dart';
import 'package:ble_ota_app/src/ble/ble.dart';
import 'package:ble_ota_app/src/ble/ble_scanner.dart';
import 'package:ble_ota_app/src/ble/ble_uuids.dart';
import 'package:ble_ota_app/src/ui/status_screen.dart';
import 'package:ble_ota_app/src/ui/upload_screen.dart';

class ScanerScreen extends StatefulWidget {
  const ScanerScreen({Key? key}) : super(key: key);

  @override
  State<ScanerScreen> createState() => ScanerScreenState();
}

class ScanerScreenState extends State<ScanerScreen> {
  void _evaluateBleStatus(BleStatus status) {
    setState(() {
      if (status == BleStatus.ready) {
        _startScan();
      } else if (status != BleStatus.unknown) {
        _stopScan();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StatusScreen()),
        );
      }
    });
  }

  void _startScan() {
    Wakelock.enable();
    bleScanner.startScan([serviceUuid]);

    Future.delayed(const Duration(seconds: 10), () {
      _stopScan();
    });
  }

  void _stopScan() {
    Wakelock.disable();
    bleScanner.stopScan();
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
      appBar: AppBar(
        title: const Text("Devices"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: StreamBuilder<BleScanState>(
            stream: bleScanner.stateStream,
            builder: (context, snapshot) => Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: ListView(
                    children: bleScanner.state.discoveredDevices
                        .map(
                          (device) => Card(
                            child: ListTile(
                              title: Text(device.name),
                              subtitle:
                                  Text("${device.id}\nRSSI: ${device.rssi}"),
                              leading: const Icon(Icons.bluetooth),
                              onTap: () async {
                                _stopScan();
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
                          ),
                        )
                        .toList(),
                  ),
                ),
                if (bleScanner.state.scanIsInProgress)
                  const CircularProgressIndicator(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.search),
                      label: const Text('Scan'),
                      onPressed: !bleScanner.state.scanIsInProgress
                          ? _startScan
                          : null,
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.search_off),
                      label: const Text('Stop'),
                      onPressed:
                          bleScanner.state.scanIsInProgress ? _stopScan : null,
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
