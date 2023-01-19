import 'package:flutter/material.dart';
import 'package:arduino_ble_ota_app/src/ble/ble_scanner.dart';
import 'package:arduino_ble_ota_app/src/ble/ble_connector.dart';
import 'package:arduino_ble_ota_app/src/ble/ble_uuids.dart';
import 'package:arduino_ble_ota_app/src/ui/upload_screen.dart';

class ScanerScreen extends StatefulWidget {
  const ScanerScreen({Key? key}) : super(key: key);

  @override
  State<ScanerScreen> createState() => ScanerScreenState();
}

class ScanerScreenState extends State<ScanerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
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
                          subtitle: Text("${device.id}\nRSSI: ${device.rssi}"),
                          leading: const Icon(Icons.bluetooth),
                          onTap: () async {
                            bleScanner.stopScan();
                            bleConnector.connect(device.id);
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      UploadScreen(deviceId: device.id)),
                            );
                            bleConnector.disconnect(device.id);
                            bleScanner.startScan([serviceUuid]);
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: bleScanner.state.scanIsInProgress
                    ? () => bleScanner.stopScan()
                    : () => bleScanner.startScan([serviceUuid]),
                child:
                    Text(bleScanner.state.scanIsInProgress ? 'Stop' : 'Scan'),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
