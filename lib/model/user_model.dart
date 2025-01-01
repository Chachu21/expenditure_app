import 'package:flutter/foundation.dart';

class UserModel extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _username;

  bool get isAuthenticated => _isAuthenticated;
  String? get username => _username;

  void login(String username) {
    _username = username;
    _isAuthenticated = true;
    notifyListeners();
  }

  void logout() {
    _username = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
