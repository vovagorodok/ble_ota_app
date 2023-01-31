import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ble_ota_app/src/core/device_info.dart';
import 'package:ble_ota_app/src/core/remote_info.dart';
import 'package:ble_ota_app/src/core/softwate_info.dart';
import 'package:ble_ota_app/src/core/state_stream.dart';

class HttpInfoReader extends StatefulStream<RemoteInfoState> {
  RemoteInfoState _state = RemoteInfoState(info: RemoteInfo());

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
      _state.info.hardwareName = body["hardware_name"];
      if (_state.info.hardwareName != deviceInfo.hardwareName) {
        return;
      }
      _state.info.hardwareIcon = body["hardware_icon"];

      final softwares = body["softwares"];
      final fullList =
          softwares.map<SoftwareInfo>(SoftwareInfo.fromJson).toList();
      final filteredByHardwareList =
          fullList.where((SoftwareInfo softwareInfo) {
        return (softwareInfo.hardwareVersion != null
                ? softwareInfo.hardwareVersion == deviceInfo.hardwareVersion
                : true) &&
            (softwareInfo.minHardwareVersion != null
                ? softwareInfo.minHardwareVersion! <= deviceInfo.hardwareVersion
                : true) &&
            (softwareInfo.maxHardwareVersion != null
                ? softwareInfo.maxHardwareVersion! >= deviceInfo.hardwareVersion
                : true);
      }).toList();
      final filteredBySoftwareList =
          filteredByHardwareList.where((SoftwareInfo softwareInfo) {
        return softwareInfo.name == deviceInfo.softwareName;
      }).toList();

      state.info.softwareInfoList = filteredByHardwareList;
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
      state.info.newestSoftware = max;
    } catch (_) {}
  }

  void read(DeviceInfo deviceInfo, String hardwaresDictUrl) {
    _state = RemoteInfoState(info: RemoteInfo());
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
          state.info.unregisteredHardware = true;
        }
      } catch (_) {}

      state.ready = true;
      addStateToStream(state);
    }.call();
  }
}

class RemoteInfoState {
  RemoteInfoState({
    required this.info,
    this.ready = false,
  });

  RemoteInfo info;
  bool ready;
}
