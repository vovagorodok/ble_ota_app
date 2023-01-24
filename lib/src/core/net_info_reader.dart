import 'dart:async';
import 'dart:convert';

import 'package:ble_ota_app/src/core/hardware_info.dart';
import 'package:ble_ota_app/src/core/softwate_info.dart';
import 'package:flutter/services.dart';

class NetInfoReader {
  final StreamController<SwInfoState> _infoStreamController =
      StreamController();

  Stream<SwInfoState> get infoStream => _infoStreamController.stream;
  SwInfoState infoState = SwInfoState();

  void read(HardwareInfo hwInfo) {
    infoState.ready = false;
    _infoStreamController.add(infoState);

    () async {
      final data = await rootBundle.loadString("assets/hardwares.json");
      final body = json.decode(data);
      final hardwarePath = body[hwInfo.hwName];

      // if (hardwarePath) {
        print("VOVA: hardwarePath: $hardwarePath");
      // }

      infoState.ready = true;
      _infoStreamController.add(infoState);
    }.call();
  }
}

class SwInfoState {
  SwInfoState({
    this.swInfoList = const [],
    this.newest,
    this.ready = false,
  });

  List<SoftwareInfo> swInfoList;
  SoftwareInfo? newest;
  bool ready;
}
