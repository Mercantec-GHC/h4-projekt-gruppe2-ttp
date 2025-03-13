import 'package:flutter/material.dart';
import 'package:mobile/client.dart';
import 'package:mobile/controllers/user.dart';
import 'package:mobile/pages/home.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserController>(
            create: (_) => UserController(client: client, prefs: prefs))
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        home: Consumer<UserController>(
            builder: (_, controller, __) =>
                controller.session == null ? LoginPage() : HomePage()),
      ),
    );
  }
}
