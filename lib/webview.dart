import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mix_web_bridge/inner_bridge.dart';
import 'package:webview_flutter/webview_flutter.dart';
import './bridge_manager.dart';

class MixWebView extends StatefulWidget {
  final String? url;

  const MixWebView(this.url, {Key? key}) : super(key: key);

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
  void didPush() {
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
        debuggingEnabled: true,
        initialUrl: widget.url,
        javascriptMode: JavascriptMode.unrestricted,
        userAgent: Platform.isIOS ? _bridgeManager.injectedScript : null,
        javascriptChannels: {
          JavascriptChannel(
            name: _bridgeManager.channelName,
            onMessageReceived: (msg) => _bridgeManager.onChannelMessageReceived(msg.message),
          )
        },
        onWebViewCreated: (vc) {
          _bridgeManager.jsRunner = vc.runJavascriptReturningResult;
        });
  }
}
