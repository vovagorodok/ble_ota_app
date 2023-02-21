import 'dart:async';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:expandable/expandable.dart';
import 'package:wakelock/wakelock.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ble_ota_app/src/core/work_state.dart';
import 'package:ble_ota_app/src/core/software.dart';
import 'package:ble_ota_app/src/utils/string_forms.dart';
import 'package:ble_ota_app/src/ble_ota/uploader.dart';
import 'package:ble_ota_app/src/ble_ota/info_reader.dart';
import 'package:ble_ota_app/src/ble/ble_connector.dart';
import 'package:ble_ota_app/src/settings/settings.dart';

class UploadScreen extends StatefulWidget {
  UploadScreen({required this.deviceId, required this.deviceName, super.key})
      : uploader = Uploader(deviceId: deviceId),
        infoReader = InfoReader(deviceId: deviceId),
        bleConnector = BleConnector(deviceId: deviceId);

  final String deviceId;
  final String deviceName;
  final Uploader uploader;
  final InfoReader infoReader;
  final BleConnector bleConnector;

  @override
  State<UploadScreen> createState() => UploadScreenState();
}

class UploadScreenState extends State<UploadScreen> {
  late List<StreamSubscription> _subscriptions;

  Uploader get uploader => widget.uploader;
  InfoReader get infoReader => widget.infoReader;
  BleConnector get bleConnector => widget.bleConnector;
  UploadState get uploadState => uploader.state;
  InfoState get infoState => infoReader.state;
  BleConnectionState get connectionState => bleConnector.state;
  WorkStatus get uploadStatus => uploadState.status;
  WorkStatus get infoStatus => infoState.status;

  void _onConnectionStateChanged(BleConnectionState state) {
    setState(() {
      if (state == BleConnectionState.disconnected) {
        bleConnector.findAndConnect();
      } else if (state == BleConnectionState.connected) {
        if (!skipInfoReading.value) {
          infoReader.read(hardwaresDictUrl.value);
        }
      }
    });
  }

  void _onInfoStateChanged(InfoState state) {
    setState(() {});
  }

  void _onUploadStateChanged(UploadState state) {
    setState(() {
      if (state.status == WorkStatus.success ||
          state.status == WorkStatus.error) {
        bleConnector.disconnect();
        Wakelock.disable();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _subscriptions = [
      uploader.stateStream.listen(_onUploadStateChanged),
      infoReader.stateStream.listen(_onInfoStateChanged),
      bleConnector.stateStream.listen(_onConnectionStateChanged),
    ];
    bleConnector.connect();
  }

  @override
  void dispose() {
    () async {
      for (var subscription in _subscriptions) {
        await subscription.cancel();
      }

      await uploader.dispose();
      await infoReader.dispose();
      await bleConnector.disconnect();
      await bleConnector.dispose();
      await Wakelock.disable();
    }.call();
    super.dispose();
  }

  bool _canUpload() {
    return connectionState == BleConnectionState.connected &&
        uploadStatus != WorkStatus.working &&
        infoStatus != WorkStatus.working;
  }

  bool _canUploadLocalFile() {
    return alwaysAllowLocalFilesUpload.value ||
        infoState.remoteInfo.isHardwareUnregistered;
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['bin'],
    );

    if (result != null) {
      await Wakelock.enable();
      await uploader.uploadLocalFile(result.files.single.path!);
    }
  }

  Future<void> _uploadHttpFile(String url) async {
    await Wakelock.enable();
    await uploader.uploadHttpFile(url);
  }

  MaterialColor _determinateStatusColor() {
    if (uploadStatus == WorkStatus.working) {
      return Colors.blue;
    } else if (uploadStatus == WorkStatus.error ||
        infoStatus == WorkStatus.error) {
      return Colors.red;
    } else if (uploadStatus == WorkStatus.success) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }

  Widget _buildProgressInside() {
    if (uploadStatus == WorkStatus.working) {
      return Text(
        (uploadState.progress * 100).toStringAsFixed(1),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
          fontSize: 24,
        ),
      );
    } else if (uploadStatus == WorkStatus.error ||
        infoStatus == WorkStatus.error) {
      return const Icon(
        Icons.error,
        color: Colors.red,
        size: 56,
      );
    } else if (uploadStatus == WorkStatus.success) {
      return const Icon(
        Icons.done,
        color: Colors.green,
        size: 56,
      );
    } else {
      return CircleAvatar(
        radius: 55,
        backgroundColor: Colors.transparent,
        backgroundImage: infoState.remoteInfo.hardwareIcon != null
            ? NetworkImage(infoState.remoteInfo.hardwareIcon!)
            : null,
      );
    }
  }

  Widget _buildProgressWidget() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: uploadState.progress,
            color: _determinateStatusColor(),
            strokeWidth: 10,
            backgroundColor: _determinateStatusColor().shade200,
          ),
          Center(child: _buildProgressInside()),
        ],
      ),
    );
  }

  Widget _buildSoftwareCard(Software sw) => Card(
        child: ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey,
            backgroundImage: sw.icon != null ? NetworkImage(sw.icon!) : null,
          ),
          title: Text(sw.name),
          subtitle: Text("v${sw.version}"),
          onTap: () => _uploadHttpFile(sw.path),
          enabled: _canUpload(),
        ),
      );

  Widget _buildSoftwareList() => Column(
        children: [
          for (var sw in infoState.remoteInfo.softwareList)
            _buildSoftwareCard(sw)
        ],
      );

  Widget _buildStatusText(String text) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
          )),
    );
  }

  Widget _buildStatusWidget() {
    if (connectionState == BleConnectionState.disconnected) {
      return _buildStatusText(tr('Connecting..'));
    } else if (uploadStatus == WorkStatus.working) {
      return _buildStatusText(tr('Uploading..'));
    } else if (uploadStatus == WorkStatus.error) {
      return _buildStatusText(determineUploadError(uploadState));
    } else if (infoStatus == WorkStatus.error) {
      return _buildStatusText(determineInfoError(infoState));
    } else if (infoStatus == WorkStatus.idle) {
      return _buildStatusText(tr('Connected'));
    } else if (infoStatus == WorkStatus.working) {
      return _buildStatusText(tr('Loading..'));
    } else if (infoState.remoteInfo.softwareList.isEmpty) {
      return _buildStatusText(tr('NoAvailableSoftwares'));
    } else if (infoState.remoteInfo.newestSoftware == null) {
      return _buildStatusText(tr('NewestSoftwareAlreadyInstalled'));
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              tr('NewSoftwareAvailable:'),
              textAlign: TextAlign.left,
            ),
          ),
          _buildSoftwareCard(infoState.remoteInfo.newestSoftware!),
        ],
      );
    }
  }

  Widget _buildStatusWithSoftwareList() => ExpandableNotifier(
        child: Column(children: [
          _buildStatusWidget(),
          ScrollOnExpand(
            scrollOnExpand: true,
            scrollOnCollapse: false,
            child: ExpandablePanel(
              header: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(tr('AllAvailableSoftwares:')),
              ),
              collapsed: const SizedBox(),
              expanded: _buildSoftwareList(),
            ),
          ),
        ]),
      );

  Widget _buildStatusWithOptionallySoftwareList() {
    final buildSoftwareList = connectionState == BleConnectionState.connected &&
        infoStatus == WorkStatus.success &&
        uploadStatus != WorkStatus.working &&
        infoState.remoteInfo.softwareList.isNotEmpty;
    return buildSoftwareList
        ? _buildStatusWithSoftwareList()
        : _buildStatusWidget();
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
                  tr('Hardware:', args: [createHardwareString(infoState)]),
                ),
                Text(
                  tr('Software:', args: [createSoftwareString(infoState)]),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [_buildProgressWidget()],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      _buildStatusWithOptionallySoftwareList(),
                    ],
                  ),
                ),
                if (_canUploadLocalFile())
                  ElevatedButton.icon(
                    icon: const Icon(Icons.file_open),
                    label: Text(tr('UploadFile')),
                    onPressed: _canUpload() ? _pickFile : null,
                  ),
              ],
            ),
          ),
        ),
      );
}
