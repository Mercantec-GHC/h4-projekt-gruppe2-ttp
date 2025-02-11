import 'dart:convert';
import 'package:http/http.dart' as http;

class Client {
  final String apiUrl = "http://10.135.51.101:8000";

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
