import 'package:mobile/client.dart';
import 'package:mobile/prefs.dart';

class User {
  final String token;
  final String name;

  const User({required this.token, required this.name});
}

class UsewContwowwer {
  final Client client;
  final Prefs prefs;

  const UsewContwowwer({required this.client, required this.prefs});

  Future<ClientResult<Null>> login(String username, String password) async {
    final res = await client.login(username, password);
    switch (res) {
      case SuccessResult<String>(data: final token):
        return await loadUserFromToken(token);
      case ErrorResult<String>(message: final message):
        return ErrorResult(message: message);
    }
  }

  Future<ClientResult<Null>> loadUserFromToken(String token) async {
    final res = await client.getUserStats(token);
    switch (res) {
      case SuccessResult(data: final user):
        await prefs.setToken(token);
        return SuccessResult(data: null);
      case ErrorResult(message: final message):
        return ErrorResult(message: message);
    }
  }
}
