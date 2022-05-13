import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import './inner_bridge.dart';
import './manager.dart';

const _notFound = r'''
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width,minimum-scale=1.0,initial-scale=1.0,maximum-scale=1.0,user-scalable=no,viewport-fit=cover" />
    <meta name="format-detection" content="telephone=no">
    <meta name="wap-font-scale" content="no">
    <title>404</title>
  </head>
  <body style="text-align: center;">
    <div style="margin: 12px 0; font-size: 18px;">404 Not Found</div>
    <a style="text-decoration: none;" href="javascript:$app.route({pop: true});">Back</a>
  </body>
</html>
''';

class MixWebView extends StatefulWidget {
  final bool debuggingEnabled;
  final String? url;
  final List<WebViewCookie> initialCookies;
  final String? htmlString;
  final Function(String url, MixWebBridgeManager bm)? onPageFinished;

  const MixWebView({
    this.url,
    this.htmlString,
    this.onPageFinished,
    this.initialCookies = const [],
    this.debuggingEnabled = false,
    Key? key,
  }) : super(key: key);

  @override
  _MixWebViewState createState() => _MixWebViewState();
}

class _MixWebViewState extends State<MixWebView> with RouteAware, WidgetsBindingObserver {
  final MixWebBridgeManager _bridgeManager = MixWebBridgeManager();
  bool _onTop = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mwbRouteObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_onTop) return;
    if (state == AppLifecycleState.resumed) {
      _bridgeManager.callEvent("appResumed");
    } else if (state == AppLifecycleState.paused) {
      _bridgeManager.callEvent("appPaused");
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    mwbRouteObserver.unsubscribe(this);
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _onTop = true;
    _bridgeManager.callEvent("pageAppear");
  }

  @override
  void didPushNext() {
    _onTop = false;
    _bridgeManager.callEvent("pageDisappear");
  }

  @override
  Widget build(BuildContext context) {
    return WebView(
      debuggingEnabled: widget.debuggingEnabled,
      initialUrl: widget.url,
      initialCookies: widget.initialCookies,
      javascriptMode: JavascriptMode.unrestricted,
      userAgent: _bridgeManager.injectedJsToUserAgent(),
      javascriptChannels: {
        JavascriptChannel(
          name: _bridgeManager.channelName,
          onMessageReceived: (msg) => _bridgeManager.onChannelMessageReceived(msg.message),
        )
      },
      onWebViewCreated: (vc) {
        _bridgeManager.jsRunner = vc.runJavascriptReturningResult;
        final html = widget.htmlString;
        final url = widget.url ?? "";
        if (html != null) {
          vc.loadHtmlString(html);
        } else if (url.isEmpty) {
          vc.loadHtmlString(_notFound);
        }
      },
      onPageFinished: (url) {
        final func = widget.onPageFinished;
        if (func != null) func(url, _bridgeManager);
      },
    );
  }
}
