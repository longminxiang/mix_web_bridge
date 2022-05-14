import 'package:flutter/material.dart';
import './base.dart';

final RouteObserver<PageRoute> mwbRouteObserver = RouteObserver<PageRoute>();

class MixWebInnerBridge extends MixWebBridge {
  /// hello Handle
  MWBResponse helloHandle(MWBParams params) {
    final message = mwbConvert<String>(params["message"]) ?? "";
    if (message.isEmpty) {
      throw MWBException('message required.');
    }
    return {"message": message};
  }

  /// route Handle
  MWBResponse routeHandle(MWBParams params) {
    bool pop = mwbConvert<bool>(params["pop"]) ?? false;
    String name = mwbConvert<String>(params["name"]) ?? "";

    final navigator = mwbRouteObserver.navigator;
    if (navigator == null) {
      throw MWBException('navigator is null.');
    }
    try {
      if (pop && name.isNotEmpty) {
        navigator.popAndPushNamed(name);
      } else if (pop) {
        navigator.pop();
      } else {
        if (name.isEmpty) {
          throw MWBException('name required.');
        }
        navigator.pushNamed(name, arguments: params["data"]);
      }
    } on MWBException catch (_) {
      rethrow;
    } catch (e) {
      throw MWBException('$name: route not found');
    }
    return null;
  }

  @override
  MWBHandleMap handleMap() {
    return {"hello": helloHandle, "route": routeHandle};
  }
}
