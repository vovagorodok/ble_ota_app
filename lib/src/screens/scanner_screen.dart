import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ble_backend/ble_central.dart';
import 'package:ble_backend/ble_peripheral.dart';
import 'package:ble_backend/ble_scanner.dart';
import 'package:ble_backend/utils/timer_wrapper.dart';
import 'package:ble_ota_app/src/settings/settings.dart';
import 'package:ble_ota_app/src/ui/ui_consts.dart';
import 'package:ble_ota_app/src/ui/jumping_dots.dart';
import 'package:ble_ota_app/src/screens/status_screen.dart';
import 'package:ble_ota_app/src/screens/settings_screen.dart';
import 'package:ble_ota_app/src/screens/upload_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({
    required this.bleCentral,
    required this.bleScanner,
    super.key,
  });

  final BleCentral bleCentral;
  final BleScanner bleScanner;

  @override
  State<ScannerScreen> createState() => ScannerScreenState();
}

class ScannerScreenState extends State<ScannerScreen> {
  final scanTimer = TimerWrapper();

  BleCentral get bleCentral => widget.bleCentral;
  BleScanner get bleScanner => widget.bleScanner;

  void _evaluateBleCentralStatus(BleCentralStatus status) {
    setState(() {
      if (kIsWeb) {
      } else if (status == BleCentralStatus.ready) {
        _startScan();
      } else if (status != BleCentralStatus.unknown) {
        _stopScan();
      }

      if (status != BleCentralStatus.ready &&
          status != BleCentralStatus.unknown) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => StatusScreen(
                    bleCentral: bleCentral,
                  )),
        );
      }
    });
  }

  void _startScan() {
    WakelockPlus.enable();
    bleScanner.scan();

    if (!infiniteScan.value) {
      scanTimer.start(const Duration(seconds: 10), _stopScan);
    }
  }

  void _stopScan() {
    scanTimer.stop();
    WakelockPlus.disable();
    bleScanner.stop();
  }

  Widget _buildDeviceCard(BlePeripheral device) => Card(
        child: ListTile(
          title: Text(device.name ?? ''),
          subtitle: Text("${device.id}\nRSSI: ${device.rssi ?? ''}"),
          leading: const Icon(Icons.bluetooth_rounded),
          onTap: () async {
            _stopScan();
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UploadScreen(
                  blePeripheral: device,
                  bleConnector: device.createConnector(),
                ),
              ),
            );
          },
        ),
      );

  Widget _buildDevicesList() {
    final devices = bleScanner.state.devices;
    final additionalElement = bleScanner.state.isScanInProgress ? 1 : 0;

    return ListView.builder(
      itemCount: devices.length + additionalElement,
      itemBuilder: (context, index) => index != devices.length
          ? _buildDeviceCard(devices[index])
          : Padding(
              padding: const EdgeInsets.all(25.0),
              child: createJumpingDots(),
            ),
    );
  }

  Widget _buildScanButton() => FilledButton.icon(
        icon: const Icon(Icons.search_rounded),
        label: Text(tr('Scan')),
        onPressed: !bleScanner.state.isScanInProgress ? _startScan : null,
      );

  Widget _buildStopButton() => FilledButton.icon(
        icon: const Icon(Icons.search_off_rounded),
        label: Text(tr('Stop')),
        onPressed: bleScanner.state.isScanInProgress ? _stopScan : null,
      );

  Widget _buildControlButtons() => SizedBox(
        height: buttonHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _buildScanButton(),
            ),
            if (!kIsWeb) const SizedBox(width: buttonsSplitter),
            if (!kIsWeb)
              Expanded(
                child: _buildStopButton(),
              ),
          ],
        ),
      );

  Widget _buildPortrait() => Column(
        children: [
          Expanded(
            child: _buildDevicesList(),
          ),
          const SizedBox(height: screenPortraitSplitter),
          _buildControlButtons(),
        ],
      );

  Widget _buildLandscape() => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: _buildDevicesList(),
          ),
          const SizedBox(width: screenLandscapeSplitter),
          Expanded(
            child: _buildControlButtons(),
          ),
        ],
      );

  @override
  void initState() {
    super.initState();
    bleCentral.stateStream.listen(_evaluateBleCentralStatus);
    _evaluateBleCentralStatus(bleCentral.state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: MediaQuery.of(context).orientation == Orientation.portrait,
      appBar: AppBar(
        title: Text(tr('Devices')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () async {
              _stopScan();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(screenPadding),
        child: StreamBuilder<BleScannerState>(
          stream: bleScanner.stateStream,
          builder: (context, snapshot) => OrientationBuilder(
            builder: (context, orientation) =>
                orientation == Orientation.portrait
                    ? _buildPortrait()
                    : _buildLandscape(),
          ),
        ),
      ),
    );
  }
}
