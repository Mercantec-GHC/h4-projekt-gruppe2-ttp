import 'package:flutter/material.dart';
import 'package:mobile/logo.dart';
import 'package:mobile/apiFrontend/client.dart';
import 'package:provider/provider.dart';

class RegisterRequest extends ChangeNotifier {
  Response status = Unset();

  void register(String username, String password, BuildContext context) async {
    status = Loading();
    notifyListeners();

    var result = await Client().register(username, password, context);

    status = switch (result) {
      SuccessResult() => Success(),
      ErrorResult(message: final message) => Error(message: message)
    };
    notifyListeners();
  }
}

sealed class Response {}

final class Unset extends Response {}

final class Loading extends Response {}

final class Success extends Response {}

final class Error extends Response {
  final String message;
  Error({required this.message});
}

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  void _registerPressed() {}

  final username = TextEditingController();
  final password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<RegisterRequest>(
        create: (BuildContext context) {
          return RegisterRequest();
        },
        builder: (BuildContext context, Widget? child) {
          var registerRequest = context.watch<RegisterRequest>();
          var statusText = "";
          var isLoading = false;
          switch (registerRequest.status) {
            case Unset():
              statusText = "";
            case Loading():
              isLoading = true;
              if (isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
            case Success():
              statusText = "Success";
            case Error(message: final message):
              statusText = message;
          }
          return Row(
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
                      FilledButton(
                        onPressed: () => registerRequest.register(
                            username.text, password.text, context),
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
                        onPressed: () => Navigator.pop(context),
                        child: RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              const TextSpan(
                                  text: 'Har du allerede en konto? Klik '),
                              TextSpan(
                                text: 'her',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    decoration: TextDecoration.underline),
                              ),
                              const TextSpan(
                                  text:
                                      ' for at logge ind på din konto i stedet.'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        statusText,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ]),
              )
            ],
          );
        },
      ),
    );
  }
}
