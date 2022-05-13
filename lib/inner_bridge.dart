import 'package:flutter/material.dart';
import './bridge_manager.dart';

final RouteObserver<PageRoute> mwbRouteObserver = RouteObserver<PageRoute>();

class MixWebInnerBridge extends MixWebBridge {
  /// hello Handler
  MWBResponse helloHandle(MWBParams params) {
    final message = mwbConvert<String>(params["message"]) ?? "";
    if (message.isEmpty) {
      throw MWBException('message required.');
    }
    return {"message": message};
  }

  /// route Handler
  MWBResponse routeHandle(MWBParams params) {
    String name = mwbConvert<String>(params["name"]) ?? "";
    if (name.isEmpty) {
      throw MWBException('name required.');
    }
    final navigator = mwbRouteObserver.navigator;
    if (navigator == null) {
      throw MWBException('navigator is null.');
    }
    try {
      navigator.pushNamed(name, arguments: params["data"]);
    } catch (e) {
      debugPrint("$e");
      throw MWBException('route failed.');
    }
    return null;
  }

  @override
  MWBHandleMap handleMap() {
    return {"hello": helloHandle, "route": routeHandle};
  }
}
