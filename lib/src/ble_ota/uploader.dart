import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:ble_ota_app/src/core/work_state.dart';
import 'package:ble_ota_app/src/core/state_stream.dart';
import 'package:ble_ota_app/src/core/upload_error.dart';
import 'package:ble_ota_app/src/ble/ble_uploader.dart';

class Uploader extends StatefulStream<UploadState> {
  Uploader({required deviceId})
      : _bleUploader = BleUploader(deviceId: deviceId) {
    _bleUploader.stateStream.listen(_onBleUploadStateChanged);
  }

  final BleUploader _bleUploader;
  UploadState _state = UploadState();

  @override
  UploadState get state => _state;

  void _onBleUploadStateChanged(BleUploadState bleUploadState) {
    if (bleUploadState.status == BleUploadStatus.success) {
      state.status = WorkStatus.success;
    } else if (bleUploadState.status == BleUploadStatus.error) {
      state.status = WorkStatus.error;
      state.error = bleUploadState.error;
      state.errorCode = bleUploadState.errorCode;
    }
    state.progress = bleUploadState.progress;
    addStateToStream(state);
  }

  Future<void> uploadLocalFile(String localPath) async {
    _state = UploadState(status: WorkStatus.working);
    addStateToStream(state);

    File file = File(localPath);
    var data = await file.readAsBytes();
    _bleUploader.upload(data);
  }

  Future<void> uploadHttpFile(String url) async {
    try {
      _state = UploadState(status: WorkStatus.working);
      addStateToStream(state);

      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        _state.status = WorkStatus.error;
        _state.error = UploadError.unexpectedNetworkResponse;
        _state.errorCode = response.statusCode;
        addStateToStream(state);
        return;
      }

      _bleUploader.upload(response.bodyBytes);
    } catch (_) {
      _state.status = WorkStatus.error;
      _state.error = UploadError.generalNetworkError;
      addStateToStream(state);
    }
  }
}

class UploadState extends WorkState<WorkStatus, UploadError> {
  UploadState({
    super.status = WorkStatus.idle,
    super.error = UploadError.unknown,
    this.progress = 0.0,
  });

  double progress;
}
