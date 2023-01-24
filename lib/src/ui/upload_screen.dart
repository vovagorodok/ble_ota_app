import 'dart:io';
import 'dart:async';

import 'package:ble_ota_app/src/ble/ble_info_reader.dart';
import 'package:ble_ota_app/src/ble/ble_uploader.dart';
import 'package:ble_ota_app/src/ble/ble_connector.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ble_ota_app/src/core/hardware_info.dart';

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

  void _onInfoChanged(InfoState info) {
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
  String _buildInfoStr(InfoState info, String name, Version ver) =>
      info.ready ? "$name v${_buildVerStr(ver)}" : "reading..";
  String _buildHwStr(InfoState info) =>
      _buildInfoStr(info, info.hwInfo.hwName, info.hwInfo.hwVer);
  String _buildSwStr(InfoState info) =>
      _buildInfoStr(info, info.hwInfo.swName, info.hwInfo.swVer);

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

  String _determinateStatusText() {
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

  MaterialColor _determinateStatusColor() {
    switch (widget.bleUploader.state.status) {
      case UploadStatus.upload:
        return Colors.blue;
      case UploadStatus.end:
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
    final state = widget.bleUploader.state;
    if (state.status == UploadStatus.error) {
      return const Icon(
        Icons.error,
        color: Colors.red,
        size: 56,
      );
    } else if (state.status == UploadStatus.end) {
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
          color: state.status == UploadStatus.upload
              ? Colors.blue
              : Colors.blue.shade200,
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
                Text(
                    "Hardware: ${_buildHwStr(widget.bleInfoReader.infoState)}"),
                Text(
                    "Software: ${_buildSwStr(widget.bleInfoReader.infoState)}"),
                Text("Status: ${_determinateStatusText()}"),
                const SizedBox(height: 20),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [_buildProgressWidget()]),
                const SizedBox(height: 20),
                Flexible(
                  child: ListView(),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.file_open),
                  label: const Text('Upload file'),
                  onPressed: _isUploading() ? null : _pickFile,
                )
              ],
            ),
          ),
        ),
      );
}
