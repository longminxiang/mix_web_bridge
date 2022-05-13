import 'package:mix_web_bridge/mix_web_bridge.dart';

class MyBridge extends MixWebBridge {
  @override
  MWBHandleMap handleMap() {
    return {};
  }

  @override
  String injectJavascript() {
    return 'localStorage.token = "0330qr5kidw51ob03h9rbp7zc6n83d8m";';
  }
}
