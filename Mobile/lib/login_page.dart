import 'package:flutter/material.dart';
import 'package:mobile/logo.dart';
import 'package:mobile/register_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void _loginPressed() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child:
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
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                ),
                child: RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      const TextSpan(
                          text: 'Har du ikke en konto? Klik ',
                          style: TextStyle(color: Colors.black)),
                      TextSpan(
                        text: 'her',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            decoration: TextDecoration.underline),
                      ),
                      const TextSpan(
                          text: ' for at registrere en ny konto i stedet.',
                          style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
              ),
            ]),
          )
        ],
      ),
    );
  }
}
