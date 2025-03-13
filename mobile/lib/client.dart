import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/result.dart';

class InputStats {
  final bool won;
  final int correctAnswers;
  final int totalAnswers;

  const InputStats({
    required this.correctAnswers,
    required this.totalAnswers,
    required this.won,
  });
}

class User {
  String id;
  String username;
  Stats stats;

  User.fromJson(Map<String, dynamic> obj)
      : id = obj["id"],
        username = obj["username"],
        stats = Stats.fromJson(obj["stats"]);
}

class Stats {
  final int correctAnswers;
  final int totalAnswers;
  final int wins;
  final int gamesPlayed;

  Stats.fromJson(Map<String, dynamic> obj)
      : correctAnswers = obj["correct_answers"],
        totalAnswers = obj["total_answers"],
        wins = obj["wins"],
        gamesPlayed = obj["games_played"];
}

class Client {
  final String apiUrl = "http://127.0.0.1:8000";

  Future<Result<String>> login(String username, String password) async {
    final body = json.encode({"username": username, "password": password});

    var res = await http.post(Uri.parse("$apiUrl/login"),
        headers: {"Content-Type": "application/json"}, body: body);
    var resData = json.decode(res.body);

    if (resData["ok"]) {
      return Success(resData["token"]);
    } else {
      return Error(resData["message"]);
    }
  }

  Future<Result<Null>> register(String username, String password) async {
    final body = json.encode({"username": username, "password": password});

    var res = await http.post(Uri.parse("$apiUrl/createUser"),
        headers: {"Content-Type": "application/json"}, body: body);

    var resData = json.decode(res.body);

    if (resData["ok"]) {
      return Success(null);
    } else {
      return Error(resData["message"]);
    }
  }

  Future<Result<User>> getUserInfo(String token) async {
    final body = json.encode({"token": token});

    var res = await http.post(Uri.parse("$apiUrl/getStats"),
        headers: {"Content-Type": "application/json"}, body: body);

    var resData = await json.decode(res.body);

    if (resData["ok"]) {
      return Success(User.fromJson(resData["user"]));
    } else {
      return Error(resData["message"]);
    }
  }

  Future<Result<Null>> saveGame(String token, InputStats stats) async {
    final body = json.encode({
      "token": token,
      "stats": {
        "won": stats.won,
        "correct_answers": stats.correctAnswers,
        "total_answers": stats.totalAnswers,
      },
    });

    var res = await http.post(Uri.parse("$apiUrl/saveGame"),
        headers: {"Content-Type": "application/json"}, body: body);

    var resData = json.decode(res.body);

    if (resData["ok"]) {
      return Success(null);
    } else {
      return Error(resData["message"]);
    }
  }
}
