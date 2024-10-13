import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ble_ota_app/src/ui/ui_consts.dart';
import 'package:ble_ota_app/src/ui/jumping_dots.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({
    required this.title,
    required this.textUrl,
    this.pageUrl,
    super.key,
  });

  final String title;
  final String textUrl;
  final String? pageUrl;

  @override
  State<InfoScreen> createState() => InfoScreenState();
}

class InfoScreenState extends State<InfoScreen> {
  String? _text;

  Future<void> _fetchHttpText(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        setState(() {
          _text = '';
        });
        return;
      }

      setState(() {
        _text = response.body;
      });
    } catch (_) {
      setState(() {
        _text = '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchHttpText(widget.textUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: MediaQuery.of(context).orientation == Orientation.portrait,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.pop(context);
            }),
        actions: [
          if (widget.pageUrl != null)
            IconButton(
              icon: const Icon(Icons.language_rounded),
              onPressed: () async =>
                  await launchUrl(Uri.parse(widget.pageUrl!)),
            )
        ],
      ),
      body: SafeArea(
        child: _text != null
            ? Markdown(
                data: _text!,
                onTapLink: (String text, String? href, String title) async =>
                    await launchUrl(Uri.parse(href!)),
                padding: const EdgeInsets.all(screenPadding),
              )
            : Padding(
                padding: const EdgeInsets.all(screenPadding),
                child: createJumpingDots(),
              ),
      ),
    );
  }
}
