import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ble_ota_app/src/core/device_info.dart';
import 'package:ble_ota_app/src/core/softwate_info.dart';
import 'package:ble_ota_app/src/core/state_stream.dart';

class HttpInfoReader extends StatefulStream<RemoteInfoState> {
  RemoteInfoState _state = RemoteInfoState();

  @override
  RemoteInfoState get state => _state;

  Future<void> _readSoftware(DeviceInfo deviceInfo, String hardwareUrl) async {
    try {
      final response = await http.get(Uri.parse(hardwareUrl));
      if (response.statusCode != 200) {
        return;
      }

      final body = json.decode(response.body);
      if (!body.containsKey("hardware_name") ||
          !body.containsKey("softwares")) {
        return;
      }
      _state.hardwareName = body["hardware_name"];
      if (_state.hardwareName != deviceInfo.hardwareName) {
        return;
      }
      _state.hardwareIcon = body["hardware_icon"];

      final softwares = body["softwares"];
      final fullList =
          softwares.map<SoftwareInfo>(SoftwareInfo.fromJson).toList();
      final filteredByHardwareList = fullList.where((SoftwareInfo info) {
        return (info.hardwareVersion != null
                ? info.hardwareVersion == deviceInfo.hardwareVersion
                : true) &&
            (info.minHardwareVersion != null
                ? info.minHardwareVersion! <= deviceInfo.hardwareVersion
                : true) &&
            (info.maxHardwareVersion != null
                ? info.maxHardwareVersion! >= deviceInfo.hardwareVersion
                : true);
      }).toList();
      final filteredBySoftwareList =
          filteredByHardwareList.where((SoftwareInfo info) {
        return info.name == deviceInfo.softwareName;
      }).toList();

      state.softwareInfoList = filteredByHardwareList;
      if (filteredBySoftwareList.isEmpty) {
        return;
      }
      final max =
          filteredBySoftwareList.reduce((SoftwareInfo a, SoftwareInfo b) {
        return a.version >= b.version ? a : b;
      });
      if (max.ver <= deviceInfo.softwareVersion) {
        return;
      }
      state.newestSoftware = max;
    } catch (_) {}
  }

  void read(DeviceInfo deviceInfo, String hardwaresDictUrl) {
    _state = RemoteInfoState();
    addStateToStream(state);

    () async {
      try {
        final response = await http.get(Uri.parse(hardwaresDictUrl));
        if (response.statusCode != 200) {
          return;
        }

        final body = json.decode(response.body);
        final hardwareUrl = body[deviceInfo.hardwareName];
        if (hardwareUrl != null) {
          await _readSoftware(deviceInfo, hardwareUrl);
        } else {
          state.unregisteredHardware = true;
        }
      } catch (_) {}

      state.ready = true;
      addStateToStream(state);
    }.call();
  }
}

class RemoteInfoState {
  RemoteInfoState({
    this.hardwareName = "",
    this.hardwareIcon,
    this.softwareInfoList = const [],
    this.newestSoftware,
    this.unregisteredHardware = false,
    this.ready = false,
  });

  String hardwareName;
  String? hardwareIcon;
  List<SoftwareInfo> softwareInfoList;
  SoftwareInfo? newestSoftware;
  bool unregisteredHardware;
  bool ready;
}
