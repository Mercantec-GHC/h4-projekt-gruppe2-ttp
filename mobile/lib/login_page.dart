import 'package:flutter/material.dart';
import 'package:mobile/client.dart';
import 'package:mobile/home_page.dart';
import 'package:mobile/logo.dart';
import 'package:mobile/register_page.dart';

sealed class _LoginPageStatus {}

final class _Ready extends _LoginPageStatus {}

final class _Loading extends _LoginPageStatus {}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final username = TextEditingController();
  final password = TextEditingController();
  _LoginPageStatus _status = _Ready();

  _loginPressed(String username, String password) async {
    setState(() => _status = _Loading());
    final response = await Client().login(username, password);
    if (!mounted) return;
    setState(() => _status = _Ready());
    switch (response) {
      case SuccessResult(data: final _):
        final snackBar = SnackBar(content: Text("Logged ind!"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => HomeNavigation()));
        return;
      case ErrorResult(message: final message):
        final snackBar = SnackBar(content: Text(message));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
    }
  }

  _gotoRegister() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => RegisterPage()));
  }

  _bypassLogin() {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => HomeNavigation()));
  }

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
              SizedBox(
                width: 200,
                child: TextField(
                  controller: username,
                  decoration: InputDecoration(
                    label: Text("Brugernavn"),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 200,
                child: TextField(
                  obscureText: true,
                  controller: password,
                  decoration: InputDecoration(
                    label: Text("Adgangskode"),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _status is _Ready
                  ? FilledButton(
                      onPressed: () =>
                          _loginPressed(username.text, password.text),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "Log ind",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    )
                  : CircularProgressIndicator(),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _gotoRegister,
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
              OutlinedButton(
                onPressed: _bypassLogin,
                child: Text("bypass login 😈🙏"),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
