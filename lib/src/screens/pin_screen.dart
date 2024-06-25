import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_pin_code_fields/flutter_pin_code_fields.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ble_ota_app/src/utils/string_forms.dart';
import 'package:ble_ota_app/src/core/work_state.dart';
import 'package:ble_ota_app/src/ble/ble_pin_changer.dart';

class PinScreen extends StatefulWidget {
  PinScreen({required deviceId, required this.deviceName, super.key})
      : blePinChanger = BlePinChanger(deviceId: deviceId);

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

  void _onChange(String value) {
    setState(() {
      _pin = value.length == 6 ? int.tryParse(value) : null;
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
      return tr('Changing..');
    } else if (blePinChangeStatus == WorkStatus.error) {
      return determinePinChangeError(blePinChangeState);
    } else if (blePinChangeStatus == WorkStatus.success) {
      return tr('Changed');
    } else {
      return tr('ChangePinCode:');
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

  Widget _buildStatusWidget() => Text(
        _determinateStatusText(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: _determinateStatusColor(),
        ),
      );

  Widget _buildPinCodeWidget() => PinCodeFields(
        length: 6,
        keyboardType: TextInputType.number,
        margin: const EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 5,
        ),
        padding: const EdgeInsets.all(0),
        onChange: _onChange,
        onComplete: _onChange,
      );

  Widget _buildPinCodeWithStatusWidget() => Column(
        children: [
          _buildStatusWidget(),
          _buildPinCodeWidget(),
        ],
      );

  Widget _buildSetButton() => FilledButton.icon(
        icon: const Icon(Icons.upload_rounded),
        label: Text(tr('Set')),
        onPressed: _canSetPin() ? _setPin : null,
      );

  Widget _buildRemoveButton() => FilledButton.icon(
        icon: const Icon(Icons.delete_rounded),
        label: Text(tr('Remove')),
        onPressed: _canChange() ? _removePin : null,
      );

  Widget _buildControlButtons() => Row(
        children: [
          Expanded(
            child: _buildSetButton(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildRemoveButton(),
          ),
        ],
      );

  Widget _buildPortrait() => Column(
        children: [
          Expanded(
            child: _buildPinCodeWithStatusWidget(),
          ),
          _buildControlButtons(),
        ],
      );

  Widget _buildLandscape() => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: _buildPinCodeWithStatusWidget(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildControlButtons(),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        primary: MediaQuery.of(context).orientation == Orientation.portrait,
        appBar: AppBar(
          title: Text(widget.deviceName),
          centerTitle: true,
        ),
        body: SafeArea(
          minimum: const EdgeInsets.all(16.0),
          child: OrientationBuilder(
            builder: (context, orientation) =>
                orientation == Orientation.portrait
                    ? _buildPortrait()
                    : _buildLandscape(),
          ),
        ),
      );
}
