import 'package:flutter/material.dart';
import 'package:mobile/login_page.dart';
import 'package:mobile/logo.dart';
import 'package:mobile/gorbie.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key, required gorbie}) : _gorbie = gorbie;

  final Gorbie _gorbie;

  void _registerPressed() {}

  void _loginPressed(BuildContext context) {
    _gorbie.setRoot(LoginPage(gorbie: _gorbie));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Logo(),
        const SizedBox(height: 16),
        const SizedBox(width: 150, child: Divider()),
        const SizedBox(height: 16),
        const SizedBox(
          width: 200,
          child: TextField(
            decoration: InputDecoration(
              label: Text("Brugernavn"),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const SizedBox(
          width: 200,
          child: TextField(
            obscureText: true,
            decoration: InputDecoration(
              label: Text("Adgangskode"),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => _registerPressed(),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              "Log ind",
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => _loginPressed(context),
          child: RichText(
            text: TextSpan(
              text: 'Har du allerede en konto? Klik ',
              style: DefaultTextStyle.of(context).style,
              children: <TextSpan>[
                TextSpan(
                  text: 'her',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      decoration: TextDecoration.underline),
                ),
                const TextSpan(
                    text: ' for at logge ind på din konto i stedet.'),
              ],
            ),
          ),
        ),
      ])
    ]));
  }
}
