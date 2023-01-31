import 'package:ble_ota_app/src/core/device_info.dart';
import 'package:ble_ota_app/src/core/softwate_info.dart';
import 'package:ble_ota_app/src/core/state_stream.dart';
import 'package:ble_ota_app/src/ble/ble_info_reader.dart';
import 'package:ble_ota_app/src/http/http_info_reader.dart';

class InfoReader extends StatefulStream<InfoState> {
  InfoReader({required deviceId})
      : _bleInfoReader = BleInfoReader(deviceId: deviceId),
        _httpInfoReader = HttpInfoReader() {
    _bleInfoReader.stateStream.listen(_onDeviceInfoStateChanged);
    _httpInfoReader.stateStream.listen(_onSoftwareInfoStateChanged);
  }

  final BleInfoReader _bleInfoReader;
  final HttpInfoReader _httpInfoReader;
  late String _hardwaresDictUrl;
  InfoState _state = InfoState();

  @override
  InfoState get state => _state;

  void _onDeviceInfoStateChanged(DeviceInfoState deviceInfoState) {
    if (deviceInfoState.ready) {
      state.deviceInfo = deviceInfoState.info;
      _httpInfoReader.read(state.deviceInfo, _hardwaresDictUrl);
    }
  }

  void _onSoftwareInfoStateChanged(SoftwareInfoState softwareInfoState) {
    if (softwareInfoState.ready) {
      state.hardwareIcon = softwareInfoState.hardwareIcon;
      state.softwareInfoList = softwareInfoState.softwareInfoList;
      state.newest = softwareInfoState.newest;
      state.unregistered = softwareInfoState.unregistered;
      state.ready = true;
      addStateToStream(state);
    }
  }

  void read(String hardwaresDictUrl) {
    _hardwaresDictUrl = hardwaresDictUrl;
    _state = InfoState();
    addStateToStream(state);

    _bleInfoReader.read();
  }
}

class InfoState {
  InfoState({
    this.deviceInfo = const DeviceInfo(),
    this.hardwareIcon,
    this.softwareInfoList = const [],
    this.newest,
    this.unregistered = false,
    this.ready = false,
  });

  String _toString(name, ver) => ready ? "$name v$ver" : "reading..";
  String toHwString() =>
      _toString(deviceInfo.hardwareName, deviceInfo.hardwareVersion);
  String toSwString() =>
      _toString(deviceInfo.softwareName, deviceInfo.softwareVersion);

  DeviceInfo deviceInfo;
  String? hardwareIcon;
  List<SoftwareInfo> softwareInfoList;
  SoftwareInfo? newest;
  bool unregistered;
  bool ready;
}
