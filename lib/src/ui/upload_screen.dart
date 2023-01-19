import 'package:flutter/material.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import 'package:arduino_ble_ota_app/src/ble/ble.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({required this.deviceId, Key? key}) : super(key: key);
  final String deviceId;

  @override
  State<UploadScreen> createState() => UploadScreenState();
}

class UploadScreenState extends State<UploadScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Text(widget.deviceId),
        ),
      );
}
