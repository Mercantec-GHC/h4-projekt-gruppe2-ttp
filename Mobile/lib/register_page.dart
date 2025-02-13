import 'package:flutter/material.dart';
import 'package:mobile/login_page.dart';
import 'package:mobile/logo.dart';
import 'package:mobile/api_frontend/client.dart';

sealed class RegisterPageStatus {}

final class Ready extends RegisterPageStatus {}

final class Loading extends RegisterPageStatus {}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final username = TextEditingController();
  final password = TextEditingController();
  RegisterPageStatus status = Ready();

  _registerRequest(String username, String password) async {
    setState(() => status = Loading());
    final response = await Client().register(username, password);
    if (!mounted) return;
    setState(() => status = Ready());
    switch (response) {
      case SuccessResult<Null>():
        final snackBar = SnackBar(content: Text("Bruger oprettet!"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
        return;
      case ErrorResult<Null>(message: final message):
        final snackBar = SnackBar(content: Text(message));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Logo(),
                const SizedBox(height: 16),
                const SizedBox(width: 150, child: Divider()),
                const SizedBox(height: 16),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: username,
                    decoration: const InputDecoration(
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
                    decoration: const InputDecoration(
                      label: Text("Adgangskode"),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                status is Ready
                    ? FilledButton(
                        onPressed: () =>
                            _registerRequest(username.text, password.text),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            "Opret",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      )
                    : CircularProgressIndicator(),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => LoginPage())),
                  child: RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        const TextSpan(
                            text: 'Har du allerede en konto? Klik ',
                            style: TextStyle(color: Colors.black)),
                        TextSpan(
                          text: 'her',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              decoration: TextDecoration.underline),
                        ),
                        const TextSpan(
                            text: ' for at logge ind på din konto i stedet.',
                            style: TextStyle(color: Colors.black)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
