import 'package:flutter/material.dart';
import 'package:mobile/login_page.dart';
import 'package:mobile/gorbie.dart';

void main() {
  runApp(App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  void _setRoot(Widget root) {
    setState(() {
      _root = root;
    });
  }

  late final Gorbie gorbie = Gorbie(setRoot: (Widget root) => _setRoot(root));
  late Widget _root = LoginPage(gorbie: gorbie);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(body: _root),
    );
  }
}
