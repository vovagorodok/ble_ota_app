import 'dart:async';

import 'package:ble_ota_app/src/core/state_stream.dart';

abstract class BleConnector extends StatefulStream<BleConnectorStatus> {
  Future<void> connect();
  Future<void> disconnect();
  Future<void> scanAndConnect();
}

enum BleConnectorStatus {
  connecting,
  connected,
  disconnecting,
  disconnected,
  scanning,
}
