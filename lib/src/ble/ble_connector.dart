import 'dart:async';

import 'package:ble_ota_app/src/core/state_notifier.dart';

abstract class BleConnector extends StatefulNotifier<BleConnectorStatus> {
  Future<void> connect();
  Future<void> disconnect();
  Future<void> scanAndConnect({Duration duration});
}

enum BleConnectorStatus {
  connecting,
  connected,
  disconnecting,
  disconnected,
  scanning,
}
