import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:ble_ota_app/src/settings/settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.cached),
            onPressed: () => setState(Settings.clearCache),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(children: [
          SettingsGroup(
            title: "General",
            children: [
              CheckboxSettingsTile(
                title: 'Infinite scan:',
                settingKey: infiniteScan.key,
                defaultValue: infiniteScan.defaultValue,
              ),
            ],
          ),
          SettingsGroup(
            title: "Developers options",
            children: [
              CheckboxSettingsTile(
                title: 'Always allow local file upload:',
                settingKey: alwaysAllowLocalFileUpload.key,
                defaultValue: alwaysAllowLocalFileUpload.defaultValue,
              ),
              TextInputSettingsTile(
                title: 'Hardwares dict url:',
                settingKey: hardwaresDictUrl.key,
                initialValue: hardwaresDictUrl.defaultValue,
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
