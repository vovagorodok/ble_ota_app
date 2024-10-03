import 'package:bluez/bluez.dart';
import 'package:ble_ota_app/src/ble/ble_central.dart';
import 'package:ble_ota_app/src/ble/ble_scanner.dart';
import 'package:ble_ota_app/src/ble/bluez_scanner.dart';

class BlueZCentral extends BleCentral {
  BlueZCentral({required this.client}) {
    _init();
  }

  final BlueZClient client;
  BleCentralStatus _status = BleCentralStatus.unknown;

  @override
  BleCentralStatus get state => _status;

  @override
  BleScanner createScaner({required List<String> serviceIds}) {
    return BlueZScanner(client: client, serviceIds: serviceIds);
  }

  void _updateCentralStatus(BleCentralStatus status) {
    _status = status;
    notifyState(_status);
  }

  Future<void> _init() async {
    await client.connect();

    int attempts = 0;
    while (attempts < 10 && client.adapters.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }

    if (client.adapters.isEmpty) {
      _updateCentralStatus(BleCentralStatus.unsupported);
    } else {
      _updateCentralStatus(client.adapters.first.powered
          ? BleCentralStatus.ready
          : BleCentralStatus.poweredOff);
    }
  }
}
