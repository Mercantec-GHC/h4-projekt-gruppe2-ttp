import 'package:flutter/material.dart';
import 'package:mobile/client.dart';
import 'package:mobile/controllers/user.dart';
import 'package:mobile/pages/login.dart';
import 'package:mobile/prefs.dart';
import 'package:provider/provider.dart';

void main() async {
  final prefs = await SharedPrefs.loadPrefs();
  final client = Client();
  runApp(App(prefs: prefs, client: client));
}

class App extends StatelessWidget {
  final Prefs prefs;
  final Client client;

  const App({super.key, required this.prefs, required this.client});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: MultiProvider(
        providers: [
          Provider<UserController>(
              create: (_) => UserController(client: client, prefs: prefs))
        ],
        builder: (_, __) => Scaffold(
          body: LoginPage(),
        ),
      ),
    );
  }
}
