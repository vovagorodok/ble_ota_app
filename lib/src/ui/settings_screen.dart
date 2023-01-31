import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:ble_ota_app/src/settings/settings_pairs.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        actions: const [
          IconButton(
            icon: Icon(Icons.cached),
            onPressed: Settings.clearCache,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: ListView(children: [
            SettingsGroup(
              title: "General",
              children: [
                CheckboxSettingsTile(
                  title: 'Infinite scan:',
                  settingKey: keyInfiniteScan,
                  defaultValue: valueInfiniteScan,
                ),
              ],
            ),
            SettingsGroup(
              title: "Develoers options",
              children: [
                CheckboxSettingsTile(
                  title: 'Always allow local file upload:',
                  settingKey: keyAlwaysAllowLocalFileUpload,
                  defaultValue: valueAlwaysAllowLocalFileUpload,
                ),
                TextInputSettingsTile(
                  title: 'Hardwares dict url:',
                  settingKey: keyHardwaresDictUrl,
                  initialValue: valueHardwaresDictUrl,
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
