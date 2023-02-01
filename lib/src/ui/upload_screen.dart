import 'dart:async';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:expandable/expandable.dart';
import 'package:wakelock/wakelock.dart';
import 'package:ble_ota_app/src/core/software.dart';
import 'package:ble_ota_app/src/utils/string_forms.dart';
import 'package:ble_ota_app/src/ble_ota/uploader.dart';
import 'package:ble_ota_app/src/ble_ota/info_reader.dart';
import 'package:ble_ota_app/src/ble/ble_connector.dart';
import 'package:ble_ota_app/src/settings/settings.dart';

class UploadScreen extends StatefulWidget {
  UploadScreen({required this.deviceId, required this.deviceName, super.key})
      : uploader = Uploader(deviceId: deviceId),
        infoReader = InfoReader(deviceId: deviceId),
        bleConnector = BleConnector(deviceId: deviceId);

  final String deviceId;
  final String deviceName;
  final Uploader uploader;
  final InfoReader infoReader;
  final BleConnector bleConnector;

  @override
  State<UploadScreen> createState() => UploadScreenState();
}

class UploadScreenState extends State<UploadScreen> {
  late List<StreamSubscription> _subscriptions;

  void _onConnectionStateChanged(BleConnectionState state) {
    if (state == BleConnectionState.disconnected) {
      widget.bleConnector.findAndConnect();
    } else if (state == BleConnectionState.connected) {
      widget.infoReader.read(hardwaresDictUrl.value);
    }
  }

  void _onInfoStateChanged(InfoState state) {
    setState(() {});
  }

  void _onUploadStateChanged(UploadState state) {
    setState(() {
      if (state.status == UploadStatus.success ||
          state.status == UploadStatus.error) {
        widget.bleConnector.disconnect();
        Wakelock.disable();
      }
    });
  }

  @override
  void initState() {
    _subscriptions = [
      widget.uploader.stateStream.listen(_onUploadStateChanged),
      widget.infoReader.stateStream.listen(_onInfoStateChanged),
      widget.bleConnector.stateStream.listen(_onConnectionStateChanged),
    ];
    widget.bleConnector.connect();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    widget.bleConnector.disconnect();
    Wakelock.disable();
  }

  bool _canUpload() {
    return widget.bleConnector.state == BleConnectionState.connected &&
        widget.uploader.state.status != UploadStatus.upload &&
        widget.infoReader.state.isReady;
  }

  bool _canUploadLocalFile() {
    return alwaysAllowLocalFilesUpload.value ||
        widget.infoReader.state.remoteInfo.isHardwareUnregistered;
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['bin'],
    );

    if (result != null) {
      Wakelock.enable();
      await widget.uploader.uploadLocalFile(result.files.single.path!);
    } else {
      // User canceled the picker
    }
  }

  Future<void> _uploadHttpFile(String url) async {
    Wakelock.enable();
    await widget.uploader.uploadHttpFile(url);
  }

  MaterialColor _determinateStatusColor() {
    switch (widget.uploader.state.status) {
      case UploadStatus.upload:
        return Colors.blue;
      case UploadStatus.success:
        return Colors.green;
      case UploadStatus.error:
        return Colors.red;
      case UploadStatus.idle:
        return Colors.blue;
      default:
        return Colors.blue;
    }
  }

  Widget _buildProgressInside() {
    final uploadState = widget.uploader.state;
    final infoState = widget.infoReader.state;
    if (uploadState.status == UploadStatus.idle) {
      return CircleAvatar(
        radius: 55,
        backgroundColor: Colors.transparent,
        backgroundImage: infoState.remoteInfo.hardwareIcon != null
            ? NetworkImage(infoState.remoteInfo.hardwareIcon!)
            : null,
      );
    } else if (uploadState.status == UploadStatus.error) {
      return const Icon(
        Icons.error,
        color: Colors.red,
        size: 56,
      );
    } else if (uploadState.status == UploadStatus.success) {
      return const Icon(
        Icons.done,
        color: Colors.green,
        size: 56,
      );
    } else {
      return Text(
        (uploadState.progress * 100).toStringAsFixed(1),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
          fontSize: 24,
        ),
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
            value: widget.uploader.state.progress,
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
          onTap: () => _uploadHttpFile(sw.path),
          enabled: _canUpload(),
        ),
      );

  Widget _buildSoftwareList() => Column(
        children: [
          for (var sw in widget.infoReader.state.remoteInfo.softwareList)
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
    final bleConnectionState = widget.bleConnector.state;
    final uploadState = widget.uploader.state;
    final infoState = widget.infoReader.state;

    if (uploadState.status == UploadStatus.error) {
      return _buildStatusText(
          determineUploadError(uploadState.error, uploadState.errorCode));
    } else if (bleConnectionState == BleConnectionState.disconnected) {
      return _buildStatusText("Connecting..");
    } else if (!infoState.isReady) {
      return _buildStatusText("Loading..");
    } else if (uploadState.status == UploadStatus.upload) {
      return _buildStatusText("Uploading..");
    } else if (infoState.remoteInfo.softwareList.isEmpty) {
      return _buildStatusText("No available softwares");
    } else if (infoState.remoteInfo.newestSoftware == null) {
      return _buildStatusText("Newest software already installed");
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              "New software available:",
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
              header: const Padding(
                padding: EdgeInsets.all(10),
                child: Text("All available softwares: "),
              ),
              collapsed: const SizedBox(),
              expanded: _buildSoftwareList(),
            ),
          ),
        ]),
      );

  Widget _buildStatusWithOptionallySoftwareList() {
    final bleConnectionState = widget.bleConnector.state;
    final uploadState = widget.uploader.state;
    final infoState = widget.infoReader.state;
    final buildStatusOnly =
        bleConnectionState == BleConnectionState.disconnected ||
            !infoState.isReady ||
            uploadState.status == UploadStatus.upload ||
            infoState.remoteInfo.softwareList.isEmpty;
    return buildStatusOnly
        ? _buildStatusWidget()
        : _buildStatusWithSoftwareList();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.deviceName),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Hardware: ${createHardwareString(widget.infoReader.state)}",
                ),
                Text(
                  "Software: ${createSoftwareString(widget.infoReader.state)}",
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [_buildProgressWidget()],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      _buildStatusWithOptionallySoftwareList(),
                    ],
                  ),
                ),
                if (_canUploadLocalFile())
                  ElevatedButton.icon(
                    icon: const Icon(Icons.file_open),
                    label: const Text('Upload file'),
                    onPressed: _canUpload() ? _pickFile : null,
                  ),
              ],
            ),
          ),
        ),
      );
}
