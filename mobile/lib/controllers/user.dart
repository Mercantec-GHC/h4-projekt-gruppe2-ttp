import 'package:flutter/material.dart';
import 'package:mobile/client.dart';
import 'package:mobile/prefs.dart';
import 'package:mobile/result.dart';

class Session {
  final User user;
  final String token;

  const Session({required this.user, required this.token});
}

class UserController extends ChangeNotifier {
  final Client client;
  final Prefs prefs;
  Session? session;

  UserController({required this.client, required this.prefs}) {
    _loadFromPrefs();
  }

  void _loadFromPrefs() async {
    final token = await prefs.getToken();
    if (token == null) {
      return;
    }
    await startSessionWithToken(token);
  }

  Future<Result<Null>> login(String username, String password) async {
    final res = await client.login(username, password);
    switch (res) {
      case Success(data: final token):
        return await startSessionWithToken(token);
      case Error(message: final message):
        return Error(message);
    }
  }

  Future<Result<Null>> saveStats(String token, InputStats stats) async {
    final res = await client.saveGame(token, stats);
    switch (res) {
      case Success():
        return await startSessionWithToken(token);
      case Error(message: final message):
        return Error(message);
    }
  }

  Future<Result<Null>> startSessionWithToken(String token) async {
    final res = await client.getUserInfo(token);
    switch (res) {
      case Success(data: final user):
        await prefs.setToken(token);
        session = Session(user: user, token: token);
        notifyListeners();
        return Success(null);
      case Error(message: final message):
        await prefs.removeToken();
        return Error(message);
    }
  }
}
