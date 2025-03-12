import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs implements Prefs {
  final SharedPreferences inner;

  const SharedPrefs(this.inner);

  static Future<Prefs> loadPrefs() async {
    return SharedPrefs(await SharedPreferences.getInstance());
  }

  @override
  void setCookie(String token) async {
    await inner.setString("token", token);
  }

  @override
  Future<String?> getCookie() async {
    return inner.getString("token");
  }
}

abstract class Prefs {
  void setCookie(String token);
  Future<String?> getCookie();
}
