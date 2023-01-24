import 'dart:async';

import 'package:ble_ota_app/src/core/softwate_info.dart';
import 'package:ble_ota_app/src/core/version.dart';

class NetInfoReader {
  final StreamController<SwInfoState> _infoStreamController =
      StreamController();

  Stream<SwInfoState> get infoStream => _infoStreamController.stream;

  SwInfoState infoState = SwInfoState(
    swInfoList: [],
    newest: SoftwareInfo(
      name: "",
      ver: const Version(major: 0, minor: 0, patch: 0),
      path: "",
    ),
    hasNewest: false,
    ready: false,
  );

  Version _convertToVer(List<int> data) =>
      Version(major: data[0], minor: data[1], patch: data[2]);

  void read() {
    infoState.ready = false;
    _infoStreamController.add(infoState);

    () async {
      infoState.ready = true;

      _infoStreamController.add(infoState);
    }.call();
  }
}

class SwInfoState {
  SwInfoState({
    required this.swInfoList,
    required this.newest,
    required this.hasNewest,
    required this.ready,
  });

  List<SoftwareInfo> swInfoList;
  SoftwareInfo newest;
  bool hasNewest;
  bool ready;
}
