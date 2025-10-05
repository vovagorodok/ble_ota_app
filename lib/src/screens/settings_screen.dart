import 'package:ble_ota_app/src/settings/settings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: MediaQuery.of(context).orientation == Orientation.portrait,
      appBar: AppBar(
        title: Text(tr('Settings')),
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.pop(context);
            }),
        actions: [
          IconButton(
            icon: const Icon(Icons.cached_rounded),
            onPressed: () => setState(Settings.clearCache),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(children: [
          SettingsGroup(
            title: tr('General'),
            children: [
              SwitchSettingsTile(
                title: tr('InfiniteScan'),
                settingKey: infiniteScan.key,
                defaultValue: infiniteScan.defaultValue,
                showDivider: true,
              ),
            ],
          ),
          SettingsGroup(
            title: tr('DeveloperOptions'),
            children: [
              SwitchSettingsTile(
                title: tr('SkipInfoReading'),
                settingKey: skipInfoReading.key,
                defaultValue: skipInfoReading.defaultValue,
                showDivider: false,
              ),
              SwitchSettingsTile(
                title: tr('AlwaysAllowLocalFilesUpload'),
                settingKey: alwaysAllowLocalFilesUpload.key,
                defaultValue: alwaysAllowLocalFilesUpload.defaultValue,
                showDivider: false,
              ),
              SwitchSettingsTile(
                title: tr('SequentialUpload'),
                settingKey: sequentialUpload.key,
                defaultValue: sequentialUpload.defaultValue,
                showDivider: false,
              ),
              TextInputSettingsTile(
                title: tr('ManufacturesDictionaryLink'),
                settingKey: manufacturesDictUrl.key,
                initialValue: manufacturesDictUrl.defaultValue,
              ),
              SliderSettingsTile(
                title: tr('MaxMtuSize'),
                settingKey: maxMtuSize.key,
                min: 23,
                max: 515,
                decimalPrecision: 0,
                defaultValue: maxMtuSize.defaultValue,
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
