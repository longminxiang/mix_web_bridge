# MixWebBridge

A flutter plugin that provides webview bridge base on [webview_flutter](https://pub.dev/packages/webview_flutter).

## Getting Started

### Add dependency

    dependencies:
      mix_web_bridge: ^1.0.0


### Very simple to use

    import 'package:mix_web_bridge/mix_web_bridge.dart';

    Navigator.of(context).push(CupertinoPageRoute(
      builder: (context) => const MixWebView(url: "https://www.google.com"),
    ));

Now you can use `$app` in `Javascript`:

    const world = await $app.hello({message: "world"});
    console.log(world);
    // {message: "world"}

## Advance use

Create your web widget, run some js on page finished.

    import 'package:webview_flutter/webview_flutter.dart';
    import 'package:mix_web_bridge/mix_web_bridge.dart';

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
      void onWebViewPageFinished(String url) async {
        final title = await bridgeManager.runJs("document.title") ?? "";
        setState(() {
          _title = title.replaceAll("\"", "");
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

Using a routes map, and add to `App`.

Add `mwbRouteObserver` to navigatorObservers.

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

Using in javascript

    // route to home page
    $app.route({name: "/"});

    // route to another web page 
    $app.route({name: "/web", data: {url: "https://www.google.com"}});

    // pop
    $app.route({pop: true});


## Inner Bridge

### hello

Params

| param   | type   | required | mark          |
| ------- | ------ | -------- | ------------- |
| message | string | Y        | hello message |

Return

| name    | type   | mark |
| ------- | ------ | ---- |
| message | string |

    const world = await $app.hello({message: "world"});
    console.log(world);
    // {message: "world"}

### route

Params

| param | type   | required | mark                  |
| ----- | ------ | -------- | --------------------- |
| name  | string | N        | route name            |
| data  | object | N        | route args            |
| pop   | bool   | N        | pop the current route |

Return `null`

    // route to home page
    $app.route({name: "/"});

    // route to another web page 
    $app.route({name: "/web", data: {url: "https://www.google.com"}});

    // pop
    $app.route({pop: true});

## Event

    const eventId = $app.on("pageAppear", () => {
      console.log("page appear");
    });

    $app.on("pageDisappear", () => {
      console.log("page disappear");
    });

    $app.on("appResumed", () => {
      console.log("app resumed");
    });

    $app.on("appPaused", () => {
      console.log("app paused");
    });

    // remove event
    eventId && $app.removeEvent(eventId);

## Add your own bridge

Create a class which extend to MixWebBridge

    class MyBridge extends MixWebBridge {

      /// write your own bridge
      MWBResponse myHelloHandle(MWBParams params) {
        final name = mwbConvert<String>(params["name"]) ?? "";
        return {"message": "hello $name"};
      }

      /// binding
      @override
      MWBHandleMap handleMap() {
        return {"helloWorld": myHelloHandle};
      }

      /// run any js as you want on page started
      @override
      String injectJavascript() {
        return 'localStorage.token = "mytoken";';
      }
    }

Using in javascript

    console.log(localStorage.token);
    // mytoken

    const msg = await $app.helloWorld({name: "Eric"});
    console.log(msg);
    // {message: "hello Eric"}
