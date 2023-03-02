import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ble_ota_app/src/utils/string_forms.dart';
import 'package:ble_ota_app/src/core/work_state.dart';
import 'package:ble_ota_app/src/ble/ble_pin_changer.dart';

class PinScreen extends StatefulWidget {
  PinScreen({required this.deviceId, required this.deviceName, super.key})
      : blePinChanger = BlePinChanger(deviceId: deviceId);

  final String deviceId;
  final String deviceName;
  final BlePinChanger blePinChanger;

  @override
  State<PinScreen> createState() => PinScreenState();
}

class PinScreenState extends State<PinScreen> {
  int? _pin;
  late StreamSubscription _subscription;

  BlePinChanger get blePinChanger => widget.blePinChanger;
  BlePinChangeState get blePinChangeState => blePinChanger.state;
  WorkStatus get blePinChangeStatus => blePinChangeState.status;

  void _onBlePinStateChanged(BlePinChangeState state) {
    setState(() {
      if (blePinChangeStatus == WorkStatus.success ||
          blePinChangeStatus == WorkStatus.error) {
        _showMyDialog();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _subscription = blePinChanger.stateStream.listen(_onBlePinStateChanged);
  }

  @override
  void dispose() {
    () async {
      await _subscription.cancel();
      await blePinChanger.dispose();
    }.call();
    super.dispose();
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                if (blePinChangeStatus == WorkStatus.success)
                  const Text('Success.'),
                if (blePinChangeStatus == WorkStatus.error)
                  Text(determinePinChangeError(blePinChangeState)),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _onChanged(String value) {
    setState(() {
      _pin = value.length >= 4 ? int.tryParse(value) : null;
    });
  }

  bool _canChange() {
    return blePinChangeStatus != WorkStatus.working;
  }

  Future<void> _setPin() async {
    blePinChanger.set(_pin!);
  }

  Future<void> _clearPin() async {
    blePinChanger.clear();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.deviceName),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextField(
                  onChanged: _onChanged,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"[0-9]")),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      if (newValue.text.isEmpty) {
                        return newValue;
                      }
                      int? value = int.tryParse(newValue.text);
                      return value != null && value <= 0xFFFFFFFF
                          ? newValue
                          : oldValue;
                    }),
                  ],
                  decoration: const InputDecoration(hintText: 'Enter pin here'),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.upload),
                      label: const Text('Set'),
                      onPressed: _canChange() && _pin != null ? _setPin : null,
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                      onPressed: _canChange() ? _clearPin : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
