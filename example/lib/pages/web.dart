import 'package:flutter/cupertino.dart';
import 'package:mix_web_bridge/mix_web_bridge.dart';
import './page.dart';

class Web extends StatelessWidget {
  const Web(this.url, {Key? key}) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: "Web",
      child: MixWebView(url),
    );
  }
}
