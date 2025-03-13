import 'dart:convert';
import 'package:http/http.dart' as http;

class Client {
  final String apiUrl = "http://10.135.51.101:8000";

  Future<ClientResult<String>> login(String username, String password) async {
    final body = json.encode({"username": username, "password": password});

    var res = await http.post(Uri.parse("$apiUrl/login"),
        headers: {"Content-Type": "application/json"}, body: body);
    var resData = json.decode(res.body);

    if (resData["ok"]) {
      return SuccessResult(data: resData["token"]);
    } else {
      return ErrorResult(message: resData["message"]);
    }
  }

  Future<ClientResult<Null>> register(String username, String password) async {
    final body = json.encode({"username": username, "password": password});

    var res = await http.post(Uri.parse("$apiUrl/createUser"),
        headers: {"Content-Type": "application/json"}, body: body);

    var resData = json.decode(res.body);

    if (resData["ok"]) {
      return SuccessResult(data: null);
    } else {
      return ErrorResult(message: resData["message"]);
    }
  }

  Future<ClientResult<Map<String, dynamic>>> getUserStats(
      String username) async {
    final body = json.encode({"username": username});

    var res = await http.post(Uri.parse("$apiUrl/getstats"),
        headers: {"Content-Type": "application/json"}, body: body);

    var resData = await json.decode(res.body);

    if (resData["ok"]) {
      return SuccessResult(data: resData["stats"]);
    } else {
      return ErrorResult(message: resData["message"]);
    }
  }

  Future<ClientResult<Null>> saveGame(
    String username, {
    required bool won,
    required int correctAnswers,
    required int totalAnswers,
  }) async {
    final body = json.encode({
      "username": username,
      "won": won,
      "correctanswers": correctAnswers,
      "totalanswers": totalAnswers
    });

    var res = await http.post(Uri.parse("$apiUrl/savestats/$username"),
        headers: {"Content-Type": "application/json"}, body: body);

    var resData = json.decode(res.body);

    if (resData["ok"]) {
      return SuccessResult(data: null);
    } else {
      return ErrorResult(message: resData["message"]);
    }
  }
}

sealed class ClientResult<Data> {
  bool ok();
}

final class SuccessResult<Data> extends ClientResult<Data> {
  @override
  bool ok() {
    return true;
  }

  final Data data;

  SuccessResult({required this.data});
}

final class ErrorResult<Data> extends ClientResult<Data> {
  @override
  bool ok() {
    return false;
  }

  final String message;

  ErrorResult({required this.message});
}
