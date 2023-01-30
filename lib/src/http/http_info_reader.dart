import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ble_ota_app/src/core/hardware_info.dart';
import 'package:ble_ota_app/src/core/softwate_info.dart';
import 'package:ble_ota_app/src/core/state_stream.dart';

class HttpInfoReader extends StatefulStream<SoftwareInfoState> {
  SoftwareInfoState _state = SoftwareInfoState();

  @override
  SoftwareInfoState get state => _state;

  Future<void> _readSoftware(HardwareInfo hwInfo, String hardwarePath) async {
    try {
      final response = await http.get(Uri.parse(hardwarePath));
      if (response.statusCode != 200) {
        return;
      }

      final body = json.decode(response.body);
      if (!body.containsKey("hardware_name") ||
          !body.containsKey("softwares")) {
        return;
      }
      _state.hardwareName = body["hardware_name"];
      if (_state.hardwareName != hwInfo.hwName) {
        return;
      }
      _state.hardwareIcon = body["hardware_icon"];

      final softwares = body["softwares"];
      final fullList =
          softwares.map<SoftwareInfo>(SoftwareInfo.fromJson).toList();
      final filteredByHwList = fullList.where((SoftwareInfo info) {
        return (info.hwVer != null ? info.hwVer == hwInfo.hwVer : true) &&
            (info.minHwVer != null ? info.minHwVer! <= hwInfo.hwVer : true) &&
            (info.maxHwVer != null ? info.maxHwVer! >= hwInfo.hwVer : true);
      }).toList();
      final filteredBySwList = filteredByHwList.where((SoftwareInfo info) {
        return info.name == hwInfo.swName;
      }).toList();

      state.softwareInfoList = filteredByHwList;
      if (filteredBySwList.isEmpty) {
        return;
      }
      final max = filteredBySwList.reduce((SoftwareInfo a, SoftwareInfo b) {
        return a.ver >= b.ver ? a : b;
      });
      if (max.ver <= hwInfo.swVer) {
        return;
      }
      state.newest = max;
    } catch (_) {}
  }

  void read(HardwareInfo hwInfo, String hardwaresDictParh) {
    _state = SoftwareInfoState();
    addStateToStream(state);

    () async {
      try {
        final response = await http.get(Uri.parse(hardwaresDictParh));
        if (response.statusCode != 200) {
          return;
        }

        final body = json.decode(response.body);
        final hardwarePath = body[hwInfo.hwName];
        if (hardwarePath != null) {
          await _readSoftware(hwInfo, hardwarePath);
        } else {
          state.unregistered = true;
        }
      } catch (_) {}

      state.ready = true;
      addStateToStream(state);
    }.call();
  }
}

class SoftwareInfoState {
  SoftwareInfoState({
    this.hardwareName = "",
    this.hardwareIcon,
    this.softwareInfoList = const [],
    this.newest,
    this.unregistered = false,
    this.ready = false,
  });

  String hardwareName;
  String? hardwareIcon;
  List<SoftwareInfo> softwareInfoList;
  SoftwareInfo? newest;
  bool unregistered;
  bool ready;
}
