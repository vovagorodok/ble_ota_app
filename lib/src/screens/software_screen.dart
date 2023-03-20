import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ble_ota_app/src/core/software.dart';

class SoftwareScreen extends StatefulWidget {
  const SoftwareScreen({required this.software, super.key});

  final Software software;

  @override
  State<SoftwareScreen> createState() => SoftwareScreenState();
}

class SoftwareScreenState extends State<SoftwareScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.software.toString()),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Markdown(
          data: widget.software.text!,
        ),
      ),
    );
  }
}
