import 'dart:async';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:expandable/expandable.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ble_ota_app/src/core/work_state.dart';
import 'package:ble_ota_app/src/core/software.dart';
import 'package:ble_ota_app/src/utils/string_forms.dart';
import 'package:ble_ota_app/src/ota/uploader.dart';
import 'package:ble_ota_app/src/ota/info_reader.dart';
import 'package:ble_ota_app/src/ble/ble_backend/ble_peripheral.dart';
import 'package:ble_ota_app/src/ble/ble_backend/ble_connector.dart';
import 'package:ble_ota_app/src/settings/settings.dart';
import 'package:ble_ota_app/src/screens/pin_screen.dart';
import 'package:ble_ota_app/src/screens/info_screen.dart';

class UploadScreen extends StatefulWidget {
  UploadScreen(
      {required this.blePeripheral, required this.bleConnector, super.key})
      : uploader = Uploader(
            bleConnector: bleConnector,
            sequentialUpload: sequentialUpload.value),
        infoReader = InfoReader(bleConnector: bleConnector);

  final BlePeripheral blePeripheral;
  final BleConnector bleConnector;
  final Uploader uploader;
  final InfoReader infoReader;

  @override
  State<UploadScreen> createState() => UploadScreenState();
}

class UploadScreenState extends State<UploadScreen> {
  List<StreamSubscription> _subscriptions = [];

  BlePeripheral get blePeripheral => widget.blePeripheral;
  BleConnector get bleConnector => widget.bleConnector;
  Uploader get uploader => widget.uploader;
  InfoReader get infoReader => widget.infoReader;
  BleConnectorStatus get connectionStatus => bleConnector.state;
  UploadState get uploadState => uploader.state;
  InfoState get infoState => infoReader.state;
  WorkStatus get uploadStatus => uploadState.status;
  WorkStatus get infoStatus => infoState.status;

  void _onConnectionStateChanged(BleConnectorStatus state) {
    setState(() {
      if (state == BleConnectorStatus.connected) {
        if (!skipInfoReading.value) {
          infoReader.read(manufacturesDictUrl: manufacturesDictUrl.value);
        }
      }
    });
  }

  void _onInfoStateChanged(InfoState state) {
    setState(() {});
  }

  void _onUploadStateChanged(UploadState state) {
    setState(() {
      if (state.status == WorkStatus.success) {
        () async {
          await bleConnector.disconnect();
          if (bleConnector.isConnectToKnownDeviceSupported) {
            await bleConnector.connectToKnownDevice();
          }
        }.call();
        WakelockPlus.disable();
      } else if (state.status == WorkStatus.error) {
        WakelockPlus.disable();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _subscriptions = [
      uploader.stateStream.listen(_onUploadStateChanged),
      infoReader.stateStream.listen(_onInfoStateChanged),
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

    uploader.dispose();
    infoReader.dispose();
    bleConnector.dispose();
    super.dispose();
  }

  bool _canPop() {
    return uploadStatus != WorkStatus.working &&
        infoStatus != WorkStatus.working;
  }

  bool _canUpload() {
    return connectionStatus == BleConnectorStatus.connected &&
        uploadStatus != WorkStatus.working &&
        infoStatus != WorkStatus.working;
  }

  bool _canUploadLocalFile() {
    return skipInfoReading.value ||
        alwaysAllowLocalFilesUpload.value ||
        infoState.remoteInfo.isHardwareUnregistered;
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['bin'],
    );

    if (result != null) {
      await WakelockPlus.enable();
      result.files.single.bytes == null
          ? await uploader.uploadLocalFile(localPath: result.files.single.path!)
          : await uploader.uploadBytes(bytes: result.files.single.bytes!);
    }
  }

  Future<void> _uploadHttpFile(String url) async {
    await WakelockPlus.enable();
    await uploader.uploadHttpFile(url: url);
  }

  MaterialColor _determinateStatusColor() {
    if (uploadStatus == WorkStatus.working) {
      return Colors.blue;
    } else if (uploadStatus == WorkStatus.error ||
        infoStatus == WorkStatus.error) {
      return Colors.red;
    } else if (uploadStatus == WorkStatus.success) {
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
                tr('Hardware:', args: [createHardwareString(infoState)]),
              ),
              const Divider(),
              Text(
                tr('Software:', args: [createSoftwareString(infoState)]),
              ),
            ],
          ),
          onTap: infoState.status == WorkStatus.success &&
                  infoState.remoteInfo.hardwareText != null
              ? () async => await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InfoScreen(
                        title: infoState.remoteInfo.hardwareName,
                        url: infoState.remoteInfo.hardwareText!,
                      ),
                    ),
                  )
              : null,
          enabled: _canUpload(),
        ),
      );

  Widget _buildProgressInside() {
    if (uploadStatus == WorkStatus.working) {
      return Text(
        (uploadState.progress * 100).toStringAsFixed(1),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
          fontSize: 24,
        ),
      );
    } else if (uploadStatus == WorkStatus.error ||
        infoStatus == WorkStatus.error) {
      return const Icon(
        Icons.error_rounded,
        color: Colors.red,
        size: 56,
      );
    } else if (uploadStatus == WorkStatus.success) {
      return const Icon(
        Icons.done_rounded,
        color: Colors.green,
        size: 56,
      );
    } else {
      return CircleAvatar(
        radius: 55,
        backgroundColor: Colors.transparent,
        backgroundImage: infoState.remoteInfo.hardwareIcon != null
            ? NetworkImage(infoState.remoteInfo.hardwareIcon!)
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
            value: uploadState.progress,
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
          trailing: sw.text != null
              ? IconButton(
                  icon: const Icon(Icons.info_rounded),
                  onPressed: () async => await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InfoScreen(
                        title: sw.toString(),
                        url: sw.text!,
                      ),
                    ),
                  ),
                )
              : null,
          onTap: () => _uploadHttpFile(sw.path),
          enabled: _canUpload(),
        ),
      );

  Widget _buildSoftwareList() => Column(
        children: [
          for (var sw in infoState.remoteInfo.softwareList)
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
    } else if (uploadStatus == WorkStatus.working) {
      return _buildStatusText(tr('Uploading..'));
    } else if (uploadStatus == WorkStatus.error) {
      return _buildStatusText(determineUploadError(uploadState));
    } else if (infoStatus == WorkStatus.working) {
      return _buildStatusText(tr('Loading..'));
    } else if (infoStatus == WorkStatus.error) {
      return _buildStatusText(determineInfoError(infoState));
    } else if (connectionStatus == BleConnectorStatus.disconnected) {
      return _buildStatusText(tr('Disconnected'));
    } else if (connectionStatus == BleConnectorStatus.scanning) {
      return _buildStatusText(tr('Scanning..'));
    } else if (infoStatus == WorkStatus.idle) {
      return _buildStatusText(tr('Connected'));
    } else if (infoState.remoteInfo.softwareList.isEmpty) {
      return _buildStatusText(tr('NoAvailableSoftwares'));
    } else if (infoState.remoteInfo.newestSoftware == null) {
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
          _buildSoftwareCard(infoState.remoteInfo.newestSoftware!),
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
            infoStatus == WorkStatus.success &&
            uploadStatus != WorkStatus.working &&
            infoState.remoteInfo.softwareList.isNotEmpty;
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
        height: 50,
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
          if (_canUploadLocalFile()) const SizedBox(height: 8),
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
          const SizedBox(width: 16),
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
            IconButton(
              icon: const Icon(Icons.pin_rounded),
              onPressed: _canUpload()
                  ? () async => await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PinScreen(
                            blePeripheral: blePeripheral,
                            bleConnector: bleConnector,
                          ),
                        ),
                      )
                  : null,
            ),
          ],
        ),
        body: SafeArea(
          minimum: const EdgeInsets.all(16.0),
          child: OrientationBuilder(
            builder: (context, orientation) =>
                orientation == Orientation.portrait
                    ? _buildPortrait()
                    : _buildLandscape(),
          ),
        ),
      );
}
