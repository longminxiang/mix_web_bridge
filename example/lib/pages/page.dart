import 'package:flutter/cupertino.dart';

class AppPage extends StatelessWidget {
  const AppPage({Key? key, required this.title, required this.child}) : super(key: key);
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
