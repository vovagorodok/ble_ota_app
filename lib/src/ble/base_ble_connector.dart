import 'package:ble_ota_app/src/ble/ble_connector.dart';
import 'package:ble_ota_app/src/ble/ble_serial.dart';

abstract class BaseBleConnector extends BleConnector {
  @override
  BleSerial createSerial(
      {required String serviceId,
      required String rxCharacteristicId,
      required String txCharacteristicId}) {
    return BleSerial(
      characteristicTx: createCharacteristic(
          serviceId: serviceId, characteristicId: txCharacteristicId),
      characteristicRx: createCharacteristic(
          serviceId: serviceId, characteristicId: rxCharacteristicId),
    );
  }
}
