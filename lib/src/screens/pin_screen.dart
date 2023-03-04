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
    setState(() {});
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

  void _onChanged(String value) {
    setState(() {
      _pin = value.length >= 6 ? int.tryParse(value) : null;
    });
  }

  bool _canChange() {
    return blePinChangeStatus != WorkStatus.working;
  }

  bool _canSetPin() {
    return _canChange() && _pin != null;
  }

  void _setPin() {
    blePinChanger.set(_pin!);
  }

  void _removePin() {
    blePinChanger.remove();
  }

  String _determinateStatusText() {
    if (blePinChangeStatus == WorkStatus.working) {
      return 'Changing..';
    } else if (blePinChangeStatus == WorkStatus.error) {
      return determinePinChangeError(blePinChangeState);
    } else if (blePinChangeStatus == WorkStatus.success) {
      return 'Changed';
    } else {
      return 'Change pin:';
    }
  }

  Color? _determinateStatusColor() {
    if (blePinChangeStatus == WorkStatus.error) {
      return Colors.red;
    } else if (blePinChangeStatus == WorkStatus.success) {
      return Colors.green;
    } else {
      return null;
    }
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
                Text(
                  _determinateStatusText(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: _determinateStatusColor(),
                  ),
                ),
                const SizedBox(height: 8),
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
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter pin here',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.upload),
                      label: const Text('Set'),
                      onPressed: _canSetPin() ? _setPin : null,
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.delete),
                      label: const Text('Remove'),
                      onPressed: _canChange() ? _removePin : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
