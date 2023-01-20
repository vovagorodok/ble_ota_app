import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:arduino_ble_ota_app/src/ble/ble.dart';
import 'package:arduino_ble_ota_app/src/ble/ble_uuids.dart';
import 'package:arduino_ble_ota_app/src/ble/ble_head_code.dart';

class BleUploader {
  BleUploader({required String deviceId})
      : _characteristicRx =
            _crateCharacteristic(characteristicUuidRx, deviceId),
        _characteristicTx =
            _crateCharacteristic(characteristicUuidTx, deviceId) {
    ble
        .subscribeToCharacteristic(_characteristicTx)
        .listen((event) => _onDataRecived(Uint8List.fromList(event)));
  }

  final QualifiedCharacteristic _characteristicRx;
  final QualifiedCharacteristic _characteristicTx;
  final StreamController<UploadState> _stateStreamController =
      StreamController();
  Uint8List _dataToSend = Uint8List(0);
  int _offset = 0;
  int _attributeSize = 0;
  int _bufferSize = 0;

  Stream<UploadState> get stateStream => _stateStreamController.stream;

  UploadState state = UploadState(
    status: UploadStatus.idle,
    progress: 0.0,
    errorMsg: "",
  );

  void upload(Uint8List data) {
    state.status = UploadStatus.idle;
    _stateStreamController.add(state);
    _dataToSend = data;

    _sendData(
        _uint8ToBytes(HeadCode.begin) + _uint32ToBytes(_dataToSend.length));
  }

  void _sendData(List<int> data) {
    ble.writeCharacteristicWithoutResponse(_characteristicRx, value: data);
  }

  void _onDataRecived(Uint8List data) {
    var headCode = _bytesToUint8(data, 0);
    if (headCode == HeadCode.ok) {
      if (state.status == UploadStatus.idle) {
        state.status = UploadStatus.upload;
        state.progress = 0.0;
        _stateStreamController.add(state);
        _offset = 0;
        _attributeSize = _bytesToUint32(data, 1);
        _bufferSize = _bytesToUint32(data, 5);
        _sendPackages();
      } else if (state.status == UploadStatus.upload) {
        _sendPackages();
      }
    } else {
      state.status = UploadStatus.error;
      state.errorMsg = determineErrorHeadCode(headCode);
      _stateStreamController.add(state);
    }
  }

  void _sendPackages() {
    // for (var i = 0; i < 5; i++) {}
  }

  Uint8List _uint8ToBytes(int value) =>
      Uint8List(1)..buffer.asByteData().setUint8(0, value);

  Uint8List _uint32ToBytes(int value) =>
      Uint8List(4)..buffer.asByteData().setUint32(0, value, Endian.little);

  int _bytesToUint8(Uint8List data, int offset) =>
      data.buffer.asByteData().getUint8(offset);

  int _bytesToUint32(Uint8List data, int offset) =>
      data.buffer.asByteData().getUint32(offset, Endian.little);

  static _crateCharacteristic(Uuid charUuid, String deviceId) =>
      QualifiedCharacteristic(
          characteristicId: charUuid,
          serviceId: serviceUuid,
          deviceId: deviceId);
}

class UploadState {
  UploadState({
    required this.status,
    required this.progress,
    required this.errorMsg,
  });

  UploadStatus status;
  double progress;
  String errorMsg;
}

enum UploadStatus { idle, upload, end, error }
