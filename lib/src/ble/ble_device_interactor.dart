import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleDeviceInteractor {
  BleDeviceInteractor({
    required Future<List<DiscoveredService>> Function(String deviceId)
        bleDiscoverServices,
    required Future<List<int>> Function(QualifiedCharacteristic characteristic)
        readCharacteristic,
    required Future<void> Function(QualifiedCharacteristic characteristic,
            {required List<int> value})
        writeWithResponse,
    required Future<void> Function(QualifiedCharacteristic characteristic,
            {required List<int> value})
        writeWithOutResponse,
    required Stream<List<int>> Function(QualifiedCharacteristic characteristic)
        subscribeToCharacteristic,
  })  : _bleDiscoverServices = bleDiscoverServices,
        _readCharacteristic = readCharacteristic,
        _writeWithResponse = writeWithResponse,
        _writeWithoutResponse = writeWithOutResponse,
        _subScribeToCharacteristic = subscribeToCharacteristic;

  final Future<List<DiscoveredService>> Function(String deviceId)
      _bleDiscoverServices;

  final Future<List<int>> Function(QualifiedCharacteristic characteristic)
      _readCharacteristic;

  final Future<void> Function(QualifiedCharacteristic characteristic,
      {required List<int> value}) _writeWithResponse;

  final Future<void> Function(QualifiedCharacteristic characteristic,
      {required List<int> value}) _writeWithoutResponse;

  final Stream<List<int>> Function(QualifiedCharacteristic characteristic)
      _subScribeToCharacteristic;

  Future<List<DiscoveredService>> discoverServices(String deviceId) async {
    try {
      print('Start discovering services for: $deviceId');
      final result = await _bleDiscoverServices(deviceId);
      print('Discovering services finished');
      return result;
    } on Exception catch (e) {
      print('Error occured when discovering services: $e');
      rethrow;
    }
  }

  Future<List<int>> readCharacteristic(
      QualifiedCharacteristic characteristic) async {
    try {
      final result = await _readCharacteristic(characteristic);

      print('Read ${characteristic.characteristicId}: value = $result');
      return result;
    } on Exception catch (e, s) {
      print(
        'Error occured when reading ${characteristic.characteristicId} : $e',
      );
      // ignore: avoid_print
      print(s);
      rethrow;
    }
  }

  Future<void> writeCharacterisiticWithResponse(
      QualifiedCharacteristic characteristic, List<int> value) async {
    try {
      print(
          'Write with response value : $value to ${characteristic.characteristicId}');
      await _writeWithResponse(characteristic, value: value);
    } on Exception catch (e, s) {
      print(
        'Error occured when writing ${characteristic.characteristicId} : $e',
      );
      // ignore: avoid_print
      print(s);
      rethrow;
    }
  }

  Future<void> writeCharacterisiticWithoutResponse(
      QualifiedCharacteristic characteristic, List<int> value) async {
    try {
      await _writeWithoutResponse(characteristic, value: value);
      print(
          'Write without response value: $value to ${characteristic.characteristicId}');
    } on Exception catch (e, s) {
      print(
        'Error occured when writing ${characteristic.characteristicId} : $e',
      );
      // ignore: avoid_print
      print(s);
      rethrow;
    }
  }

  Stream<List<int>> subScribeToCharacteristic(
      QualifiedCharacteristic characteristic) {
    print('Subscribing to: ${characteristic.characteristicId} ');
    return _subScribeToCharacteristic(characteristic);
  }
}
