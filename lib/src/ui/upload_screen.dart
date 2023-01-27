import 'dart:io';
import 'dart:async';

import 'package:ble_ota_app/src/ble/ble_info_reader.dart';
import 'package:ble_ota_app/src/ble/ble_uploader.dart';
import 'package:ble_ota_app/src/ble/ble_connector.dart';
import 'package:ble_ota_app/src/http/http_info_reader.dart';
import 'package:ble_ota_app/src/core/softwate_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:expandable/expandable.dart';
import 'package:wakelock/wakelock.dart';
import 'package:http/http.dart' as http;

class UploadScreen extends StatefulWidget {
  UploadScreen({required this.deviceId, required this.deviceName, Key? key})
      : bleConnector = BleConnector(deviceId: deviceId),
        bleInfoReader = BleInfoReader(deviceId: deviceId),
        bleUploader = BleUploader(deviceId: deviceId),
        httpInfoReader = HttpInfoReader(),
        super(key: key);

  final String deviceId;
  final String deviceName;
  final BleConnector bleConnector;
  final BleInfoReader bleInfoReader;
  final BleUploader bleUploader;
  final HttpInfoReader httpInfoReader;

  @override
  State<UploadScreen> createState() => UploadScreenState();
}

class UploadScreenState extends State<UploadScreen> {
  late List<StreamSubscription> _subscriptions;

  void _onConnectionStateChanged(ConnectionStateUpdate state) {
    if (state.connectionState == DeviceConnectionState.disconnected) {
      widget.bleConnector.findAndConnect();
    } else if (state.connectionState == DeviceConnectionState.connected) {
      widget.bleInfoReader.read();
    }
  }

  void _onHardwareInfoStateChanged(HardwareInfoState info) {
    setState(() {
      if (info.ready) {
        widget.httpInfoReader.read(info.hwInfo);
      }
    });
  }

  void _onBleUploadStateChanged(BleUploadState state) {
    setState(() {
      if (state.status == BleUploadStatus.begin) {
        Wakelock.enable();
      } else if (state.status == BleUploadStatus.success ||
          state.status == BleUploadStatus.error) {
        Wakelock.disable();
      }
    });
  }

  void _onSoftwareInfoStateChanged(SoftwareInfoState state) {
    setState(() {});
  }

  @override
  void initState() {
    _subscriptions = [
      widget.httpInfoReader.stateStream.listen(_onSoftwareInfoStateChanged),
      widget.bleUploader.stateStream.listen(_onBleUploadStateChanged),
      widget.bleInfoReader.stateStream.listen(_onHardwareInfoStateChanged),
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

  bool _isUploaderBuisy(BleUploadStatus status) {
    return status == BleUploadStatus.begin ||
        status == BleUploadStatus.upload ||
        status == BleUploadStatus.end;
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['bin'],
    );

    if (result != null) {
      await _uploadFile(result.files.single.path!);
    } else {
      // User canceled the picker
    }
  }

  Future<void> _uploadFile(String path) async {
    File file = File(path);
    var data = await file.readAsBytes();
    widget.bleUploader.upload(data);
  }

  Future<void> _uploadHttpFile(String softwarePath) async {
    try {
      final response = await http.get(Uri.parse(softwarePath));
      if (response.statusCode != 200) {
        return;
      }

      widget.bleUploader.upload(response.bodyBytes);
    } catch (_) {} // TODO: handle
  }

  MaterialColor _determinateStatusColor() {
    switch (widget.bleUploader.state.status) {
      case BleUploadStatus.begin:
        return Colors.blue;
      case BleUploadStatus.upload:
        return Colors.blue;
      case BleUploadStatus.end:
        return Colors.blue;
      case BleUploadStatus.success:
        return Colors.green;
      case BleUploadStatus.error:
        return Colors.red;
      case BleUploadStatus.idle:
        return Colors.blue;
      default:
        return Colors.blue;
    }
  }

  Widget _buildProgressInside() {
    final state = widget.bleUploader.state;
    if (state.status == BleUploadStatus.error) {
      return const Icon(
        Icons.error,
        color: Colors.red,
        size: 56,
      );
    } else if (state.status == BleUploadStatus.success) {
      return const Icon(
        Icons.done,
        color: Colors.green,
        size: 56,
      );
    } else {
      return Text(
        (state.progress * 100).toStringAsFixed(1),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: state.status == BleUploadStatus.idle
              ? Colors.blue.shade200
              : Colors.blue,
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
            value: widget.bleUploader.state.progress,
            color: _determinateStatusColor(),
            strokeWidth: 10,
            backgroundColor: _determinateStatusColor().shade200,
          ),
          Center(child: _buildProgressInside()),
        ],
      ),
    );
  }

  Widget _buildSoftwareCard(SoftwareInfo sw) => Card(
        child: ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey,
            backgroundImage: sw.icon != null ? NetworkImage(sw.icon!) : null,
          ),
          title: Text(sw.name),
          subtitle: Text("v${sw.ver}"),
          onTap: () => _uploadHttpFile(sw.path),
          enabled: !_isUploaderBuisy(widget.bleUploader.state.status),
        ),
      );

  Widget _buildSoftwareList() => Column(
        children: [
          for (var sw in widget.httpInfoReader.state.softwareInfoList)
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

  Widget _buildSoftwareStatus() {
    final bleUploadState = widget.bleUploader.state;
    final softwareInfoState = widget.httpInfoReader.state;
    if (bleUploadState.status == BleUploadStatus.error) {
      return _buildStatusText(bleUploadState.errorMsg);
    } else if (!softwareInfoState.ready) {
      return _buildStatusText("Loading..");
    } else if (softwareInfoState.softwareInfoList.isEmpty) {
      return _buildStatusText("No available softwares");
    } else if (softwareInfoState.newest == null) {
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
          _buildSoftwareCard(softwareInfoState.newest!),
        ],
      );
    }
  }

  Widget _buildExpandedSoftwareList() => ExpandableNotifier(
        child: Column(children: [
          _buildSoftwareStatus(),
          ScrollOnExpand(
            scrollOnExpand: true,
            scrollOnCollapse: false,
            child: ExpandablePanel(
              theme: const ExpandableThemeData(
                headerAlignment: ExpandablePanelHeaderAlignment.center,
              ),
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

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(widget.deviceName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    )),
                Text("Hardware: ${widget.bleInfoReader.state.toHwString()}"),
                Text("Software: ${widget.bleInfoReader.state.toSwString()}"),
                const SizedBox(height: 25),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [_buildProgressWidget()]),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      _buildExpandedSoftwareList(),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.file_open),
                  label: const Text('Upload file'),
                  onPressed: _isUploaderBuisy(widget.bleUploader.state.status)
                      ? null
                      : _pickFile,
                ),
              ],
            ),
          ),
        ),
      );
}
