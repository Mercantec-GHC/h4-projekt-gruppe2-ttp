import 'package:flutter/material.dart';
import 'package:mobile/logo.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void _loginPressed() {}

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
          onPressed: _loginPressed,
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              "Log ind",
              style: TextStyle(fontSize: 20),
            ),
          ),
        )
      ])
    ]);
  }
}
