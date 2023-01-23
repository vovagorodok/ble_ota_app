import 'dart:io';
import 'dart:async';

import 'package:ble_ota_app/src/ble/ble_info_reader.dart';
import 'package:ble_ota_app/src/ble/ble_uploader.dart';
import 'package:ble_ota_app/src/ble/ble_connector.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class UploadScreen extends StatefulWidget {
  UploadScreen({required this.deviceId, required this.deviceName, Key? key})
      : bleConnector = BleConnector(deviceId: deviceId),
        bleInfoReader = BleInfoReader(deviceId: deviceId),
        bleUploader = BleUploader(deviceId: deviceId),
        super(key: key);

  final String deviceId;
  final String deviceName;
  final BleConnector bleConnector;
  final BleInfoReader bleInfoReader;
  final BleUploader bleUploader;

  @override
  State<UploadScreen> createState() => UploadScreenState();
}

class UploadScreenState extends State<UploadScreen> {
  late StreamSubscription<ConnectionStateUpdate> _connection;

  void _onConnectionStateChanged(ConnectionStateUpdate state) {
    if (state.connectionState == DeviceConnectionState.disconnected) {
      widget.bleConnector.findAndConnect();
    } else if (state.connectionState == DeviceConnectionState.connected) {
      widget.bleInfoReader.read();
    }
  }

  void _onInfoChanged(Info info) {
    setState(() {});
  }

  void _onUploadStateChanged(UploadState state) {
    setState(() {});
  }

  @override
  void initState() {
    widget.bleUploader.stateStream.listen(_onUploadStateChanged);
    widget.bleInfoReader.infoStream.listen(_onInfoChanged);
    _connection =
        widget.bleConnector.stateStream.listen(_onConnectionStateChanged);
    widget.bleConnector.connect();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _connection.cancel();
    widget.bleConnector.disconnect();
  }

  bool _isUploading() => widget.bleUploader.state.status == UploadStatus.upload;
  String _buildVerStr(Version ver) => "${ver.major}.${ver.minor}.${ver.patch}";
  String _buildInfoStr(Info info, String name, Version ver) =>
      info.ready ? "${info.hwName} v${_buildVerStr(info.hwVer)}" : "reading..";
  String _buildHwStr(Info info) => _buildInfoStr(info, info.hwName, info.hwVer);
  String _buildSwStr(Info info) => _buildInfoStr(info, info.swName, info.swVer);

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

  String _determinateUpdateStatus() {
  switch (widget.bleUploader.state.status) {
    case UploadStatus.upload:
      return "Uploading..";
    case UploadStatus.end:
      return "Success!";
    case UploadStatus.error:
      return "Error: ${widget.bleUploader.state.errorMsg}";
    case UploadStatus.idle:
      return "Ready";
    default:
      return "Unknown status";
  }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Padding(
          padding: const EdgeInsets.fromLTRB(25.0, 35.0, 25.0, 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(widget.deviceName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("Hardware: ${_buildHwStr(widget.bleInfoReader.info)}"),
              Text("Software: ${_buildSwStr(widget.bleInfoReader.info)}"),
              Text("Status: ${_determinateUpdateStatus()}"),
              LinearProgressIndicator(value: widget.bleUploader.state.progress),
              ElevatedButton.icon(
                icon: const Icon(Icons.file_open),
                label: const Text('Upload file'),
                onPressed: _isUploading() ? null : _pickFile,
              )
            ],
          ),
        ),
      );
}
