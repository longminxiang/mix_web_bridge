import 'dart:async';
import 'dart:convert';

/// convert type safely
T? mwbConvert<T extends Object>(dynamic p) => p is T ? p : null;

typedef MWBParams = Map<String, dynamic>;
typedef MWBResponse = FutureOr<Map<String, dynamic>?>;
typedef MWBHandle = MWBResponse Function(MWBParams params);
typedef MWBHandleMap = Map<String, MWBHandle>;

class MWBException implements Exception {
  final int code;
  final String? message;

  MWBException(this.message, {this.code = 0});

  String get jsonString => json.encode({"code": code, "message": message});
}

abstract class MixWebBridge {
  MWBHandleMap handleMap();

  String injectJavascript() => "";
}
