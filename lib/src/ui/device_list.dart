import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:arduino_ble_ota_app/src/ble/ble_device_connector.dart';
import 'package:arduino_ble_ota_app/src/ble/ble_scanner_old.dart';
import 'package:arduino_ble_ota_app/src/ui/device_interactor_screen.dart';

Uuid serviceUuid = Uuid.parse("15c155ca-36c5-11ed-adc0-9741d6a72f04");

class DeviceListScreen extends StatelessWidget {
  const DeviceListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Consumer3<BleScanner, BleScannerState?, BleDeviceConnector>(
        builder: (_, bleScanner, bleScannerState, bleDeviceConnector, __) =>
            _DeviceList(
          scannerState: bleScannerState ??
              const BleScannerState(
                discoveredDevices: [],
                scanIsInProgress: false,
              ),
          startScan: bleScanner.startScan,
          stopScan: bleScanner.stopScan,
          deviceConnector: bleDeviceConnector,
        ),
      );
}

class _DeviceList extends StatefulWidget {
  const _DeviceList({
    required this.scannerState,
    required this.startScan,
    required this.stopScan,
    required this.deviceConnector,
  });

  final BleDeviceConnector deviceConnector;
  final BleScannerState scannerState;
  final void Function(List<Uuid>) startScan;
  final VoidCallback stopScan;
  @override
  __DeviceListState createState() => __DeviceListState();
}

class __DeviceListState extends State<_DeviceList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: ListView(
                children: widget.scannerState.discoveredDevices
                    .map(
                      (device) => ListTile(
                        title: Text(device.name),
                        subtitle: Text("${device.id}\nRSSI: ${device.rssi}"),
                        leading: const Icon(Icons.bluetooth),
                        onTap: () async {
                          widget.stopScan();
                          widget.deviceConnector.connect(device.id);
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DeviceInteractorScreen(
                                    deviceId: device.id)),
                          );
                          widget.deviceConnector.disconnect(device.id);
                          widget.startScan([serviceUuid]);
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
                ElevatedButton(
                    child: const Text('Scan'),
                    onPressed: !widget.scannerState.scanIsInProgress
                        ? () => widget.startScan([serviceUuid])
                        : null),
                ElevatedButton(
                  child: const Text('Stop'),
                  onPressed: widget.scannerState.scanIsInProgress
                      ? widget.stopScan
                      : null,
                ),
              ],
            ),
            const SizedBox(
              height: 25,
            ),
          ],
        ),
      ),
    );
  }
}
