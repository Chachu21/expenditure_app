import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  final SharedPreferences _prefs;
  bool _isAuthenticated = false;

  AuthService(this._prefs) {
    _isAuthenticated = _prefs.getBool('isAuthenticated') ?? false;
  }

  bool get isAuthenticated => _isAuthenticated;

  Future<bool> login(String username, String password) async {
    // In a real app, you'd validate credentials against a server or local storage
    if (username == 'admin' && password == 'password') {
      _isAuthenticated = true;
      await _prefs.setBool('isAuthenticated', true);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    await _prefs.setBool('isAuthenticated', false);
    notifyListeners();
  }
}
