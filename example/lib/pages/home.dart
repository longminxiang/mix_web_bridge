import 'package:flutter/cupertino.dart';
import './page.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: "Home",
      child: Column(
        children: [
          CupertinoButton(
            child: const Text("Push webview"),
            onPressed: () {
              Navigator.of(context).pushNamed("/web", arguments: {"url": "http://localhost:8080"});
            },
          ),
        ],
      ),
    );
  }
}
