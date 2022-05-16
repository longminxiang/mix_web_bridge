import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import './inner_bridge.dart';
import './base.dart';

class MixWebBridgeManager {
  static final _innerBridge = MixWebInnerBridge();
  static List<MixWebBridge> _bridges = [_innerBridge];

  static setup({List<MixWebBridge>? bridges}) {
    if (bridges != null) _bridges = [_innerBridge, ...bridges];
  }

  Future<String> Function(String js)? jsRunner;

  MWBHandleMap get _handleMap {
    MWBHandleMap handleMap = {};
    for (final b in _bridges) {
      handleMap.addAll(b.handleMap());
    }
    return handleMap;
  }

  final String channelName = "mix_web_bridge";

  onChannelMessageReceived(String message) async {
    Map<String, dynamic>? map;
    try {
      map = json.decode(message) as Map<String, dynamic>;
    } catch (e) {/**/}
    if (map == null) {
      debugPrint("post message unaccepted: $message");
      return;
    }
    String resFunc;
    try {
      final name = mwbConvert<String>(map["name"]);
      final handle = _handleMap[name];
      if (handle == null) {
        throw MWBException('handle $handle not found.');
      }
      MWBParams? params;
      try {
        params = mwbConvert<MWBParams>(map["params"]);
      } catch (e) {
        throw MWBException('params must be map or null.');
      }
      final data = await handle(params ?? {});
      final dataStr = data != null ? json.encode(data) : "";
      resFunc = 'resolve($dataStr)';
    } on MWBException catch (e) {
      resFunc = 'reject(${e.jsonString})';
    } catch (e) {
      final error = MWBException('unhandle error.');
      debugPrint("$e");
      resFunc = 'reject(${error.jsonString})';
    }

    final cbid = mwbConvert<String>(map["cbid"]) ?? "";
    if (cbid.isNotEmpty) {
      final js = '\$app._cbs["$cbid"].$resFunc; delete \$app._cbs["$cbid"];';
      runJs(js);
    }
  }

  String get _injectedScript {
    const global = r'''
window.__$app = {
  _cbs: {}, _ecbs: [], _ran: () => parseInt(Math.random() * 100000),
  bridgeName: "mix_web_bridge",
  send(name, params) {
    return new Promise((resolve, reject) => {
      const cbid = `${name}__${this._ran()}`;
      const message = JSON.stringify({ name, params, cbid });
      this._cbs[cbid] = { resolve, reject };
      window[this.bridgeName].postMessage(message);
    }).catch(e => console.log(e));
  },
  on(name, cb) {
    const eid = `${name}__${this._ran()}`; this._ecbs.push({eid, cb});
    return eid;
  },
  removeEvent(eid) { this._ecbs = this._ecbs.filter(e => e.eid !== eid) },
}
window.$app = window.__$app;
''';
    final methods = _handleMap.keys.map((k) => '\$app.$k = (p) => \$app.send("$k", p);');
    final js = _bridges.map((e) => e.injectJavascript()).where((e) => e != "");
    return global + methods.join("\n") + "\n" + js.join(";\n");
  }

  /// android
  void injectedJsOnPageStarted(String url) {
    if (Platform.isAndroid) {
      runJs(_injectedScript);
    }
  }

  /// ios
  String? injectedJsToUserAgent({String? ua}) {
    final aua = ua ?? "";
    if (Platform.isIOS) {
      final b64 = base64.encode(utf8.encode(_injectedScript));
      return '<injectedjs>$b64</injectedjs>$aua';
    }
    return ua;
  }

  callEvent(String name, {Map<String, dynamic>? data}) {
    final datastr = json.encode(data);
    final js = '\$app._ecbs.forEach(e => e.eid.startsWith(`${name}__`) && e.cb($datastr));';
    return runJs(js);
  }

  Future<String?> runJs(String js) {
    final c = Completer<String?>();
    runZonedGuarded(() async {
      final runner = jsRunner;
      if (runner != null) {
        final re = await runner(js);
        c.complete(re);
      } else {
        debugPrint("js runner js null");
        c.complete();
      }
    }, (Object error, StackTrace stack) {
      debugPrint("run js error: $error");
      c.complete();
    });
    return c.future;
  }
}
