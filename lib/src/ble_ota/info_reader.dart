import 'package:ble_ota_app/src/core/device_info.dart';
import 'package:ble_ota_app/src/core/errors.dart';
import 'package:ble_ota_app/src/core/remote_info.dart';
import 'package:ble_ota_app/src/core/work_state.dart';
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
    if (deviceInfoState.status == WorkStatus.success) {
      state.deviceInfo = deviceInfoState.info;
      _httpInfoReader.read(state.deviceInfo, _hardwaresDictUrl);
    }
  }

  void _onRemoteInfoStateChanged(RemoteInfoState remoteInfoState) {
    if (remoteInfoState.status == WorkStatus.success) {
      state.remoteInfo = remoteInfoState.info;
      state.status = WorkStatus.success;
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

class InfoState extends WorkState<WorkStatus, InfoError> {
  InfoState({
    super.status = WorkStatus.idle,
    super.error = InfoError.unknown,
    this.deviceInfo = const DeviceInfo(),
    required this.remoteInfo,
  });

  DeviceInfo deviceInfo;
  RemoteInfo remoteInfo;
}
