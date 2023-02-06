import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ble_ota_app/src/core/errors.dart';
import 'package:ble_ota_app/src/core/work_state.dart';
import 'package:ble_ota_app/src/core/device_info.dart';
import 'package:ble_ota_app/src/core/remote_info.dart';
import 'package:ble_ota_app/src/core/software.dart';
import 'package:ble_ota_app/src/core/state_stream.dart';

class HttpInfoReader extends StatefulStream<RemoteInfoState> {
  RemoteInfoState _state = RemoteInfoState(info: RemoteInfo());

  @override
  RemoteInfoState get state => _state;

  void _readNewestSoftware(DeviceInfo deviceInfo) {
    final filteredBySoftwareList =
        state.info.softwareList.where((Software software) {
      return software.name == deviceInfo.softwareName;
    }).toList();
    if (filteredBySoftwareList.isEmpty) {
      return;
    }
    final max = filteredBySoftwareList.reduce((Software a, Software b) {
      return a.version >= b.version ? a : b;
    });
    if (max.version <= deviceInfo.softwareVersion) {
      return;
    }
    state.info.newestSoftware = max;
  }

  Future<void> _readSoftwares(DeviceInfo deviceInfo, String hardwareUrl) async {
    try {
      final response = await http.get(Uri.parse(hardwareUrl));
      if (response.statusCode != 200) {
        _raiseError(
          InfoError.unexpectedNetworkResponse,
          errorCode: response.statusCode,
        );
        return;
      }

      final body = json.decode(response.body);
      if (!body.containsKey("hardware_name") ||
          !body.containsKey("softwares")) {
        _raiseError(InfoError.incorrectJsonFileFormat);
        return;
      }
      _state.info.hardwareName = body["hardware_name"];
      if (_state.info.hardwareName != deviceInfo.hardwareName) {
        _raiseError(InfoError.incorrectJsonFileFormat);
        return;
      }
      _state.info.hardwareIcon = body["hardware_icon"];

      final softwares = body["softwares"];
      final fullList = softwares.map<Software>(Software.fromJson).toList();
      final filteredByHardwareList = fullList.where((Software software) {
        return (software.hardwareVersion != null
                ? software.hardwareVersion == deviceInfo.hardwareVersion
                : true) &&
            (software.minHardwareVersion != null
                ? software.minHardwareVersion! <= deviceInfo.hardwareVersion
                : true) &&
            (software.maxHardwareVersion != null
                ? software.maxHardwareVersion! >= deviceInfo.hardwareVersion
                : true);
      }).toList();
      state.info.softwareList = filteredByHardwareList;

      _readNewestSoftware(deviceInfo);
      state.status = WorkStatus.success;
      addStateToStream(state);
    } catch (_) {
      _raiseError(InfoError.generalNetworkError);
    }
  }

  void _raiseError(InfoError error, {int errorCode = 0}) {
    state.status = WorkStatus.error;
    state.error = error;
    state.errorCode = errorCode;
    addStateToStream(state);
  }

  void read(DeviceInfo deviceInfo, String hardwaresDictUrl) {
    _state = RemoteInfoState(
      status: WorkStatus.working,
      info: RemoteInfo(),
    );
    addStateToStream(state);

    () async {
      try {
        final response = await http.get(Uri.parse(hardwaresDictUrl));
        if (response.statusCode != 200) {
          _raiseError(
            InfoError.unexpectedNetworkResponse,
            errorCode: response.statusCode,
          );
          return;
        }

        final body = json.decode(response.body);
        final hardwareUrl = body[deviceInfo.hardwareName];
        if (hardwareUrl != null) {
          await _readSoftwares(deviceInfo, hardwareUrl);
        } else {
          state.info.isHardwareUnregistered = true;
          state.status = WorkStatus.success;
          addStateToStream(state);
        }
      } catch (_) {
        _raiseError(InfoError.generalNetworkError);
      }
    }.call();
  }
}

class RemoteInfoState extends WorkState<WorkStatus, InfoError> {
  RemoteInfoState({
    super.status = WorkStatus.idle,
    super.error = InfoError.unknown,
    required this.info,
  });

  RemoteInfo info;
}
