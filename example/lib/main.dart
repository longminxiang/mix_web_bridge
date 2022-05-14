import 'package:flutter/cupertino.dart';
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

void main() async {
  MixWebBridgeManager.setup(
    bridges: [MyBridge()],
  );
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

/// Home
class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _AppPage(
      title: "Home",
      child: CupertinoButton(
        child: const Text("Push webview"),
        onPressed: () {
          Navigator.of(context).pushNamed("/web");
        },
      ),
    );
  }
}

/// Web
class Web extends StatefulWidget {
  final String? url;
  const Web({this.url, Key? key}) : super(key: key);

  @override
  _WebState createState() => _WebState();
}

class _WebState extends MixWebViewState<Web> {
  String _title = "";
  late final Widget webView = buildWebView(url: widget.url);

  @override
  void didGetTitle(String title) {
    setState(() {
      _title = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _AppPage(
      title: _title,
      child: webView,
    );
  }
}

/// App Page
class _AppPage extends StatelessWidget {
  const _AppPage({Key? key, required this.title, required this.child}) : super(key: key);
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(title)),
      backgroundColor: const Color.fromRGBO(247, 247, 247, 1),
      resizeToAvoidBottomInset: true,
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 44),
        child: child,
      ),
    );
  }
}
