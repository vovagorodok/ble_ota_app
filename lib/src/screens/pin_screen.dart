import 'dart:async';

import 'package:ble_backend/ble_peripheral.dart';
import 'package:ble_ota_app/src/ui/ui_consts.dart';
import 'package:ble_ota_app/src/utils/string_forms.dart';
import 'package:ble_ota/ble_ota.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_pin_code_fields/flutter_pin_code_fields.dart';
import 'package:flutter/material.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({
    required this.blePeripheral,
    required this.bleOta,
    super.key,
  });

  final BlePeripheral blePeripheral;
  final BleOta bleOta;

  @override
  State<PinScreen> createState() => PinScreenState();
}

class PinScreenState extends State<PinScreen> {
  int? _pin;
  StreamSubscription? _subscription;

  BleOta get bleOta => widget.bleOta;
  BleOtaState get bleOtaState => bleOta.state;
  BleOtaStatus get bleOtaStatus => bleOtaState.status;

  void _onBleOtaStateChanged(BleOtaState state) {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _subscription = bleOta.stateStream.listen(_onBleOtaStateChanged);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _onChange(String value) {
    setState(() {
      _pin = value.length == 6 ? int.tryParse(value) : null;
    });
  }

  bool _canChange() {
    return bleOtaStatus != BleOtaStatus.pinChange;
  }

  bool _canSetPin() {
    return _canChange() && _pin != null;
  }

  void _setPin() {
    bleOta.setPin(pin: _pin!);
  }

  void _removePin() {
    bleOta.removePin();
  }

  String _determinateStatusText() {
    if (bleOtaStatus == BleOtaStatus.pinChange) {
      return tr('Changing..');
    } else if (bleOtaStatus == BleOtaStatus.error) {
      return determineError(bleOtaState);
    } else if (bleOtaStatus == BleOtaStatus.pinChanged) {
      return tr('Changed');
    } else {
      return tr('ChangePinCode:');
    }
  }

  Color? _determinateStatusColor() {
    if (bleOtaStatus == BleOtaStatus.error) {
      return Colors.red;
    } else if (bleOtaStatus == BleOtaStatus.pinChanged) {
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

  Widget _buildControlButtons() => SizedBox(
        height: buttonHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _buildSetButton(),
            ),
            const SizedBox(width: buttonsSplitter),
            Expanded(
              child: _buildRemoveButton(),
            ),
          ],
        ),
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
          const SizedBox(width: screenLandscapeSplitter),
          Expanded(
            child: _buildControlButtons(),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        primary: MediaQuery.of(context).orientation == Orientation.portrait,
        appBar: AppBar(
          title: Text(widget.blePeripheral.name ?? ''),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: _canChange()
                ? () {
                    Navigator.pop(context);
                  }
                : null,
          ),
        ),
        body: SafeArea(
          minimum: const EdgeInsets.all(screenPadding),
          child: OrientationBuilder(
            builder: (context, orientation) =>
                orientation == Orientation.portrait
                    ? _buildPortrait()
                    : _buildLandscape(),
          ),
        ),
      );
}
