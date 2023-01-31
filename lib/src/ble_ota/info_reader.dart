import 'package:ble_ota_app/src/core/device_info.dart';
import 'package:ble_ota_app/src/core/remote_info.dart';
import 'package:ble_ota_app/src/core/state_stream.dart';
import 'package:ble_ota_app/src/ble/ble_info_reader.dart';
import 'package:ble_ota_app/src/http/http_info_reader.dart';

class InfoReader extends StatefulStream<InfoState> {
  InfoReader({required deviceId})
      : _bleInfoReader = BleInfoReader(deviceId: deviceId),
        _httpInfoReader = HttpInfoReader() {
    _bleInfoReader.stateStream.listen(_onDeviceInfoStateChanged);
    _httpInfoReader.stateStream.listen(_onRemoteInfoStateChanged);
  }

  final BleInfoReader _bleInfoReader;
  final HttpInfoReader _httpInfoReader;
  late String _hardwaresDictUrl;
  InfoState _state = InfoState(remoteInfo: RemoteInfo());

  @override
  InfoState get state => _state;

  void _onDeviceInfoStateChanged(DeviceInfoState deviceInfoState) {
    if (deviceInfoState.isReady) {
      state.deviceInfo = deviceInfoState.info;
      _httpInfoReader.read(state.deviceInfo, _hardwaresDictUrl);
    }
  }

  void _onRemoteInfoStateChanged(RemoteInfoState remoteInfoState) {
    if (remoteInfoState.isReady) {
      state.remoteInfo = remoteInfoState.info;
      state.isReady = true;
      addStateToStream(state);
    }
  }

  void read(String hardwaresDictUrl) {
    _hardwaresDictUrl = hardwaresDictUrl;
    _state = InfoState(remoteInfo: RemoteInfo());
    addStateToStream(state);

    _bleInfoReader.read();
  }
}

class InfoState {
  InfoState({
    this.deviceInfo = const DeviceInfo(),
    required this.remoteInfo,
    this.isReady = false,
  });

  String _toString(name, ver) => isReady ? "$name v$ver" : "reading..";
  String toHardwareString() =>
      _toString(deviceInfo.hardwareName, deviceInfo.hardwareVersion);
  String toSoftwareString() =>
      _toString(deviceInfo.softwareName, deviceInfo.softwareVersion);

  DeviceInfo deviceInfo;
  RemoteInfo remoteInfo;
  bool isReady;
}
