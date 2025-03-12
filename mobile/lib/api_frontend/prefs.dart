import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs implements Prefs {
  final SharedPreferences inner;

  const SharedPrefs(this.inner);

  @override
  Future<Prefs> getPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPrefs(prefs);
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
  Future<Prefs> getPrefs();
  void setCookie(String token);
  Future<String?> getCookie();
}
