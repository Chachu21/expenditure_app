import 'package:expenditure_app/model/user_model.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final UserModel _userModel;

  AuthService(this._userModel);

  bool get isAuthenticated => _userModel.isAuthenticated;

  void login(String username, String password) {
    // In a real app, you would validate credentials here
    _userModel.login(username);
    notifyListeners();
  }

  void logout() {
    _userModel.logout();
    notifyListeners();
  }
}
