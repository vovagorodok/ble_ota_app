import 'dart:io';

import 'package:ble_ota_app/src/core/state_stream.dart';
import 'package:ble_ota_app/src/ble/ble_uploader.dart';
import 'package:http/http.dart' as http;

class Uploader extends StatefulStream<UploadState> {
  Uploader({required deviceId})
      : bleUploader = BleUploader(deviceId: deviceId) {
    bleUploader.stateStream.listen(_onBleUploadStateChanged);
  }

  final BleUploader bleUploader;

  UploadStatus _status = UploadStatus.idle;

  @override
  UploadState get state => UploadState(
        status: _status,
        progress: bleUploader.state.progress,
        errorMsg: bleUploader.state.errorMsg,
      );

  void _onBleUploadStateChanged(BleUploadState bleUploadState) {
    if (bleUploadState.status == BleUploadStatus.success) {
      _status = UploadStatus.success;
    } else if (bleUploadState.status == BleUploadStatus.error) {
      _status = UploadStatus.error;
    }
    addStateToStream(state);
  }

  Future<void> uploadLocalFile(String localPath) async {
    _status = UploadStatus.upload;
    addStateToStream(state);

    File file = File(localPath);
    var data = await file.readAsBytes();
    bleUploader.upload(data);
  }

  Future<void> uploadHttpFile(String url) async {
    try {
      _status = UploadStatus.upload;
      addStateToStream(state);

      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        return;
      }

      bleUploader.upload(response.bodyBytes);
    } catch (_) {
      _status = UploadStatus.error;
      addStateToStream(state);
    }
  }
}

class UploadState {
  UploadState({
    this.status = UploadStatus.idle,
    this.progress = 0.0,
    this.errorMsg = "",
  });

  UploadStatus status;
  double progress;
  String errorMsg;
}

enum UploadStatus { idle, upload, success, error }
