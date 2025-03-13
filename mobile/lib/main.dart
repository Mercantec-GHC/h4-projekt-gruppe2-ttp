import 'package:flutter/material.dart';
import 'package:mobile/pages/login.dart';
import 'package:mobile/prefs.dart';

void main() async {
  final prefs = await SharedPrefs.loadPrefs();
  runApp(App(prefs: prefs));
}

class App extends StatelessWidget {
  final Prefs prefs;

  const App({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        body: LoginPage(),
      ),
    );
  }
}
