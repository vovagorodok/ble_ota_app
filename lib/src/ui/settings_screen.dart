import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:easy_localization/easy_localization.dart';
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
        title: Text(tr('Settings')),
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
            title: tr('General'),
            children: [
              CheckboxSettingsTile(
                title: tr('InfiniteScan'),
                settingKey: infiniteScan.key,
                defaultValue: infiniteScan.defaultValue,
              ),
            ],
          ),
          SettingsGroup(
            title: tr('DeveloperOptions'),
            children: [
              CheckboxSettingsTile(
                title: tr('AlwaysAllowLocalFileUpload'),
                settingKey: alwaysAllowLocalFileUpload.key,
                defaultValue: alwaysAllowLocalFileUpload.defaultValue,
              ),
              TextInputSettingsTile(
                title: tr('HardwaresDictionaryLink'),
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
