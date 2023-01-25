import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ble_ota_app/src/ble/ble.dart';
import 'package:ble_ota_app/src/ble/ble_uuids.dart';
import 'package:ble_ota_app/src/ble/ble_consts.dart';

class BleUploader {
  BleUploader({required this.deviceId})
      : _characteristicRx =
            _crateCharacteristic(characteristicUuidRx, deviceId),
        _characteristicTx =
            _crateCharacteristic(characteristicUuidTx, deviceId) {
    _subscribeToCharacteristic();
  }

  final String deviceId;
  final QualifiedCharacteristic _characteristicRx;
  final QualifiedCharacteristic _characteristicTx;
  final StreamController<UploadState> _stateStreamController =
      StreamController();
  Uint8List _dataToSend = Uint8List(0);
  int _currentDataPos = 0;
  int _currentBufferSize = 0;
  int _packageMaxSize = 0;
  int _bufferMaxSize = 0;

  Stream<UploadState> get stateStream => _stateStreamController.stream;
  UploadState state = UploadState();

  void upload(Uint8List data) {
    if (state.status == UploadStatus.end) {
      _subscribeToCharacteristic();
    }
    state = UploadState();
    _stateStreamController.add(state);
    _dataToSend = data;
    _sendBegin();
  }

  void _sendData(List<int> data) {
    ble.writeCharacteristicWithoutResponse(_characteristicRx, value: data);
  }

  void _sendBegin() {
    _sendData(
        _uint8ToBytes(HeadCode.begin) + _uint32ToBytes(_dataToSend.length));
  }

  void _handleResp(Uint8List data) {
    var headCode = _bytesToUint8(data, headCodePos);
    if (headCode == HeadCode.ok) {
      if (state.status == UploadStatus.idle) {
        _handleBeginResp(data);
        _sendPackages();
      } else if (state.status == UploadStatus.upload) {
        _sendPackages();
      } else if (state.status == UploadStatus.end) {
        _stateStreamController.add(state);
      }
    } else {
      state.status = UploadStatus.error;
      state.errorMsg = determineErrorHeadCode(headCode);
      _stateStreamController.add(state);
    }
  }

  void _handleBeginResp(Uint8List data) {
    state.status = UploadStatus.upload;
    state.progress = 0.0;
    _stateStreamController.add(state);
    _currentDataPos = 0;
    _currentBufferSize = 0;
    _packageMaxSize = _bytesToUint32(data, attrSizePos) - headCodeBytesNum;
    _bufferMaxSize = _bytesToUint32(data, bufferSizePos);

    // TODO: fix and remove
    ble.requestMtu(
        deviceId: deviceId, mtu: _packageMaxSize + headCodeBytesNum + 4);
  }

  void _sendPackages() {
    while (_currentDataPos < _dataToSend.length) {
      var packageSize =
          min(_dataToSend.length - _currentDataPos, _packageMaxSize);
      var packageEndPos = _currentDataPos + packageSize;

      _sendData(_uint8ToBytes(HeadCode.package) +
          _dataToSend.sublist(_currentDataPos, packageEndPos));
      _currentDataPos = packageEndPos;

      state.progress =
          _currentDataPos.toDouble() / _dataToSend.length.toDouble();
      _stateStreamController.add(state);

      _currentBufferSize += packageSize;
      if (_currentBufferSize > _bufferMaxSize) {
        _currentBufferSize = packageSize;
        return;
      }
    }

    _sendEnd();
  }

  void _sendEnd() {
    _sendData(
        _uint8ToBytes(HeadCode.end) + _uint32ToBytes(getCrc32(_dataToSend)));
    state.status = UploadStatus.end;
  }

  Uint8List _uint8ToBytes(int value) =>
      Uint8List(1)..buffer.asByteData().setUint8(0, value);

  Uint8List _uint32ToBytes(int value) =>
      Uint8List(4)..buffer.asByteData().setUint32(0, value, Endian.little);

  int _bytesToUint8(Uint8List data, int offset) =>
      data.buffer.asByteData().getUint8(offset);

  int _bytesToUint32(Uint8List data, int offset) =>
      data.buffer.asByteData().getUint32(offset, Endian.little);

  void _subscribeToCharacteristic() {
    ble
        .subscribeToCharacteristic(_characteristicTx)
        .listen((event) => _handleResp(Uint8List.fromList(event)));
  }

  static _crateCharacteristic(Uuid charUuid, String deviceId) =>
      QualifiedCharacteristic(
          characteristicId: charUuid,
          serviceId: serviceUuid,
          deviceId: deviceId);
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

enum UploadStatus { idle, upload, end, error }
