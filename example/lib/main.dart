import 'package:flutter/cupertino.dart';
import 'package:mix_web_bridge/mix_web_bridge.dart';
import './pages/home.dart';
import './pages/web.dart';
import './mybridge.dart';

void main() async {
  MixWebBridgeManager.setBridges([MyBridge()]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final Map<String, WidgetBuilder> _routes = {
    '/': (contxt) => const Home(),
    '/web': (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final url = args != null && args["url"] is String ? args["url"] as String : null;
      return Web(url: url);
    },
  };

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      navigatorObservers: [mwbRouteObserver],
      title: 'App',
      routes: _routes,
      supportedLocales: const [Locale('en', '')],
    );
  }
}
