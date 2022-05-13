import 'package:flutter/cupertino.dart';
import 'package:mix_web_bridge/mix_web_bridge.dart';
import './page.dart';

class Web extends StatefulWidget {
  final String? url;
  const Web({this.url, Key? key}) : super(key: key);

  @override
  _WebState createState() => _WebState();
}

class _WebState extends State<Web> {
  String _title = "";

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: _title,
      child: MixWebView(
        url: widget.url,
        debuggingEnabled: true,
        onPageFinished: (url, bm) async {
          final title = await bm.runJs("document.title");
          setState(() {
            _title = title ?? "";
          });
        },
      ),
    );
  }
}
