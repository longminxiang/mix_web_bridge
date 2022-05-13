import 'package:flutter/cupertino.dart';
import 'package:mix_web_bridge/mix_web_bridge.dart';
import './pages/home.dart';
import './pages/web.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key) {
    MixWebBridgeManager.setBridges([MixWebInnerBridge()]);
  }

  final Map<String, WidgetBuilder> _routes = {
    '/': (contxt) => const Home(),
    '/web': (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final url = args != null && args["url"] is String ? args["url"] as String : "";
      return Web(url);
    },
  };

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      navigatorObservers: [mwbRouteObserver],
      title: 'App',
      initialRoute: '/',
      routes: _routes,
      supportedLocales: const [Locale('en', '')],
    );
  }
}
