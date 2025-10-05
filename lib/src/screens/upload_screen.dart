import 'dart:async';

import 'package:ble_backend/ble_connector.dart';
import 'package:ble_backend/ble_peripheral.dart';
import 'package:ble_ota_app/src/screens/info_screen.dart';
import 'package:ble_ota_app/src/screens/pin_screen.dart';
import 'package:ble_ota_app/src/settings/settings.dart';
import 'package:ble_ota_app/src/ui/ui_consts.dart';
import 'package:ble_ota_app/src/utils/string_forms.dart';
import 'package:ble_ota/ble_ota.dart';
import 'package:ble_ota/core/software.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expandable/expandable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class UploadScreen extends StatefulWidget {
  UploadScreen({
    required this.blePeripheral,
    required this.bleConnector,
    super.key,
  }) : bleOta = BleOta(
            bleConnector: bleConnector,
            manufacturesDictUrl: manufacturesDictUrl.value,
            maxMtuSize: maxMtuSize.value.toInt(),
            skipInfoReading: skipInfoReading.value,
            sequentialUpload: sequentialUpload.value);

  final BlePeripheral blePeripheral;
  final BleConnector bleConnector;
  final BleOta bleOta;

  @override
  State<UploadScreen> createState() => UploadScreenState();
}

class UploadScreenState extends State<UploadScreen> {
  List<StreamSubscription> _subscriptions = [];

  BlePeripheral get blePeripheral => widget.blePeripheral;
  BleConnector get bleConnector => widget.bleConnector;
  BleOta get bleOta => widget.bleOta;
  BleConnectorStatus get connectionStatus => bleConnector.state;
  BleOtaState get bleOtaState => bleOta.state;
  BleOtaStatus get bleOtaStatus => bleOtaState.status;

  void _onConnectionStateChanged(BleConnectorStatus state) {
    setState(() {
      if (state == BleConnectorStatus.connected) {
        bleOta.init();
      }
    });
  }

  void _onBleOtaStateChanged(BleOtaState state) {
    setState(() {
      if (state.status == BleOtaStatus.uploaded) {
        () async {
          await bleConnector.disconnect();
          if (bleConnector.isConnectToKnownDeviceSupported) {
            await bleConnector.connectToKnownDevice();
          }
        }.call();
      } else if (state.status == BleOtaStatus.initialized ||
          state.status == BleOtaStatus.error) {
        WakelockPlus.disable();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _subscriptions = [
      bleOta.stateStream.listen(_onBleOtaStateChanged),
      bleConnector.stateStream.listen(_onConnectionStateChanged),
    ];
    bleConnector.connect();
  }

  @override
  void dispose() {
    () async {
      await bleConnector.disconnect();
      for (var subscription in _subscriptions) {
        await subscription.cancel();
      }
    }.call();
    WakelockPlus.disable();

    bleOta.dispose();
    bleConnector.dispose();
    super.dispose();
  }

  bool _isBleOtaActive() {
    return bleOtaStatus == BleOtaStatus.idle ||
        bleOtaStatus == BleOtaStatus.init ||
        bleOtaStatus == BleOtaStatus.upload ||
        bleOtaStatus == BleOtaStatus.pinChange;
  }

  bool _isBleOtaInitialized() {
    return bleOtaStatus != BleOtaStatus.idle &&
        bleOtaStatus != BleOtaStatus.init;
  }

  bool _isRemoteInfoNotAvailable() {
    return _isBleOtaInitialized() && !bleOtaState.remoteInfo.isAvailable;
  }

  bool _canPop() {
    return !_isBleOtaActive();
  }

  bool _canUpload() {
    return connectionStatus == BleConnectorStatus.connected &&
        !_isBleOtaActive() &&
        bleOtaState.deviceFlags.uploadEnabled;
  }

  bool _canUploadLocalFile() {
    return skipInfoReading.value ||
        alwaysAllowLocalFilesUpload.value ||
        _isRemoteInfoNotAvailable();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['bin'],
    );

    if (result != null) {
      await WakelockPlus.enable();
      result.files.single.bytes == null
          ? await bleOta.uploadLocalFile(localPath: result.files.single.path!)
          : await bleOta.uploadBytes(bytes: result.files.single.bytes!);
    }
  }

  Future<void> _uploadHttpFile(Software sw) async {
    await WakelockPlus.enable();
    await bleOta.uploadHttpFile(url: sw.path, size: sw.size);
  }

  MaterialColor _determinateStatusColor() {
    if (bleOtaStatus == BleOtaStatus.upload) {
      return Colors.blue;
    } else if (bleOtaStatus == BleOtaStatus.error) {
      return Colors.red;
    } else if (bleOtaStatus == BleOtaStatus.uploaded) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }

  Widget _buildPripheralInfoWidget() => Card.outlined(
        child: ListTile(
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('Hardware:', args: [createHardwareString(bleOtaState)]),
              ),
              const Divider(),
              Text(
                tr('Software:', args: [createSoftwareString(bleOtaState)]),
              ),
            ],
          ),
          onTap: bleOtaState.remoteInfo.isAvailable &&
                  (bleOtaState.remoteInfo.hardwareText != null ||
                      bleOtaState.remoteInfo.hardwarePage != null)
              ? bleOtaState.remoteInfo.hardwareText == null
                  ? () async => await launchUrl(
                      Uri.parse(bleOtaState.remoteInfo.hardwarePage!))
                  : () async => await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InfoScreen(
                            title: bleOtaState.remoteInfo.hardwareName,
                            textUrl: bleOtaState.remoteInfo.hardwareText!,
                            pageUrl: bleOtaState.remoteInfo.hardwarePage,
                          ),
                        ),
                      )
              : null,
          enabled: _canUpload(),
        ),
      );

  Widget _buildProgressInside() {
    if (bleOtaStatus == BleOtaStatus.upload) {
      return Text(
        (bleOtaState.uploadProgress * 100).toStringAsFixed(1),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
          fontSize: 24,
        ),
      );
    } else if (bleOtaStatus == BleOtaStatus.error) {
      return const Icon(
        Icons.error_rounded,
        color: Colors.red,
        size: 56,
      );
    } else if (bleOtaStatus == BleOtaStatus.uploaded) {
      return const Icon(
        Icons.done_rounded,
        color: Colors.green,
        size: 56,
      );
    } else {
      return CircleAvatar(
        radius: 55,
        backgroundColor: Colors.transparent,
        backgroundImage: bleOtaState.remoteInfo.hardwareIcon != null
            ? NetworkImage(bleOtaState.remoteInfo.hardwareIcon!)
            : null,
      );
    }
  }

  Widget _buildProgressWidget() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: bleOtaState.uploadProgress,
            color: _determinateStatusColor(),
            strokeWidth: 10,
            backgroundColor: _determinateStatusColor().shade200,
          ),
          Center(child: _buildProgressInside()),
        ],
      ),
    );
  }

  Widget _buildSoftwareCard(Software sw) => Card(
        child: ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey,
            backgroundImage: sw.icon != null ? NetworkImage(sw.icon!) : null,
          ),
          title: Text(sw.name),
          subtitle: Text("v${sw.version}"),
          trailing: sw.text != null || sw.page != null
              ? IconButton(
                  icon: Icon(sw.text == null
                      ? Icons.language_rounded
                      : Icons.info_rounded),
                  onPressed: sw.text == null
                      ? () async => await launchUrl(Uri.parse(sw.page!))
                      : () async => await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InfoScreen(
                                title: sw.toString(),
                                textUrl: sw.text!,
                                pageUrl: sw.page,
                              ),
                            ),
                          ),
                )
              : null,
          onTap: () => _uploadHttpFile(sw),
          enabled: _canUpload(),
        ),
      );

  Widget _buildSoftwareList() => Column(
        children: [
          for (var sw in bleOtaState.remoteInfo.softwareList)
            _buildSoftwareCard(sw)
        ],
      );

  Widget _buildStatusText(String text) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
          )),
    );
  }

  Widget _buildStatusWidget() {
    if (connectionStatus == BleConnectorStatus.connecting) {
      return _buildStatusText(tr('Connecting..'));
    } else if (connectionStatus == BleConnectorStatus.disconnecting) {
      return _buildStatusText(tr('Disconnecting..'));
    } else if (connectionStatus == BleConnectorStatus.disconnected) {
      return _buildStatusText(tr('Disconnected'));
    } else if (connectionStatus == BleConnectorStatus.scanning) {
      return _buildStatusText(tr('Scanning..'));
    } else if (bleOtaStatus == BleOtaStatus.init) {
      return _buildStatusText(tr('Loading..'));
    } else if (bleOtaStatus == BleOtaStatus.upload) {
      return _buildStatusText(tr('Uploading..'));
    } else if (bleOtaStatus == BleOtaStatus.error) {
      return _buildStatusText(determineError(bleOtaState));
    } else if (!bleOtaState.remoteInfo.isAvailable) {
      return _buildStatusText(tr('Connected'));
    } else if (bleOtaState.remoteInfo.softwareList.isEmpty) {
      return _buildStatusText(tr('NoAvailableSoftwares'));
    } else if (bleOtaState.remoteInfo.newestSoftware == null) {
      return _buildStatusText(tr('NewestSoftwareAlreadyInstalled'));
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              tr('NewSoftwareAvailable:'),
              textAlign: TextAlign.left,
            ),
          ),
          _buildSoftwareCard(bleOtaState.remoteInfo.newestSoftware!),
        ],
      );
    }
  }

  Widget _buildStatusWithSoftwareList() => ExpandableNotifier(
        child: Column(children: [
          _buildStatusWidget(),
          ScrollOnExpand(
            scrollOnExpand: true,
            scrollOnCollapse: false,
            child: ExpandablePanel(
              header: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(tr('AllAvailableSoftwares:')),
              ),
              collapsed: const SizedBox(),
              expanded: _buildSoftwareList(),
            ),
          ),
        ]),
      );

  Widget _buildStatusWithOptionallySoftwareList() {
    final buildSoftwareList =
        connectionStatus == BleConnectorStatus.connected &&
            !_isBleOtaActive() &&
            bleOtaState.remoteInfo.isAvailable &&
            bleOtaState.remoteInfo.softwareList.isNotEmpty;
    return buildSoftwareList
        ? _buildStatusWithSoftwareList()
        : _buildStatusWidget();
  }

  Widget _buildSoftwareStatusWidget() => Expanded(
        child: ListView(
          children: [
            _buildStatusWithOptionallySoftwareList(),
          ],
        ),
      );

  Widget _buildUploadFileButton() => SizedBox(
        height: buttonHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.file_open_rounded),
                label: Text(tr('UploadFile')),
                onPressed: _canUpload() ? _pickFile : null,
              ),
            ),
          ],
        ),
      );

  Widget _buildPortrait() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPripheralInfoWidget(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_buildProgressWidget()],
          ),
          const SizedBox(height: 20),
          _buildSoftwareStatusWidget(),
          if (_canUploadLocalFile())
            const SizedBox(height: screenPortraitSplitter),
          if (_canUploadLocalFile()) _buildUploadFileButton(),
        ],
      );

  Widget _buildLandscape() => Row(
        children: [
          Expanded(
            child: Column(
              children: [
                _buildPripheralInfoWidget(),
                _buildSoftwareStatusWidget(),
              ],
            ),
          ),
          const SizedBox(width: screenLandscapeSplitter),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: _canUploadLocalFile()
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [_buildProgressWidget()],
                ),
                const SizedBox(height: 20),
                if (_canUploadLocalFile()) _buildUploadFileButton(),
              ],
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        primary: MediaQuery.of(context).orientation == Orientation.portrait,
        appBar: AppBar(
          title: Text(blePeripheral.name ?? ''),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: _canPop()
                ? () {
                    Navigator.pop(context);
                  }
                : null,
          ),
          actions: [
            if (bleOtaState.deviceFlags.pinChangeSupported)
              IconButton(
                icon: const Icon(Icons.pin_rounded),
                onPressed: _canUpload()
                    ? () async => await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PinScreen(
                              blePeripheral: blePeripheral,
                              bleOta: bleOta,
                            ),
                          ),
                        )
                    : null,
              ),
          ],
        ),
        body: SafeArea(
          minimum: const EdgeInsets.all(screenPadding),
          child: OrientationBuilder(
            builder: (context, orientation) =>
                orientation == Orientation.portrait
                    ? _buildPortrait()
                    : _buildLandscape(),
          ),
        ),
      );
}
