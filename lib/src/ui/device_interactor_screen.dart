import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:arduino_ble_ota_app/src/ble/ble_device_interactor.dart';
import 'package:arduino_ble_ota_app/src/ble/ble_uuids.dart';

class DeviceInteractorScreen extends StatelessWidget {
  final String deviceId;
  const DeviceInteractorScreen({Key? key, required this.deviceId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Consumer2<ConnectionStateUpdate, BleDeviceInteractor>(
          builder: (_, connectionStateUpdate, deviceInteractor, __) {
            if (connectionStateUpdate.connectionState ==
                DeviceConnectionState.connected) {
              return DeviceInteractor(
                deviceId: deviceId,
                deviceInteractor: deviceInteractor,
              );
            } else if (connectionStateUpdate.connectionState ==
                DeviceConnectionState.connecting) {
              return const Text('connecting');
            } else {
              return const Text('error');
            }
          },
        ),
      ),
    );
  }
}

class DeviceInteractor extends StatefulWidget {
  final BleDeviceInteractor deviceInteractor;

  final String deviceId;
  const DeviceInteractor(
      {Key? key, required this.deviceInteractor, required this.deviceId})
      : super(key: key);

  @override
  State<DeviceInteractor> createState() => _DeviceInteractorState();
}

class _DeviceInteractorState extends State<DeviceInteractor> {
  Stream<List<int>>? subscriptionStream;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('connected'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: subscriptionStream != null
                  ? null
                  : () async {
                      setState(() {
                        subscriptionStream =
                            widget.deviceInteractor.subScribeToCharacteristic(
                          QualifiedCharacteristic(
                              characteristicId: characteristicUuidHwName,
                              serviceId: serviceUuid,
                              deviceId: widget.deviceId),
                        );
                      });
                    },
              child: const Text('subscribe'),
            ),
            const SizedBox(
              width: 20,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('disconnect'),
            ),
          ],
        ),
        subscriptionStream != null
            ? StreamBuilder<List<int>>(
                stream: subscriptionStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    print(snapshot.data);
                    return Text(snapshot.data.toString());
                  }
                  return const Text('No data yet');
                })
            : const Text('Stream not initalized')
      ],
    );
  }
}
