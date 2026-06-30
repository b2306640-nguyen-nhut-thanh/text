import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../models/user.dart';

class AuthManager with ChangeNotifier {
  User? _loggedInUser;

  bool get isAuth {
    return _loggedInUser != null;
  }

  User? get user {
    return _loggedInUser;
  }

  Future<User> signup(String email, String password) {
    _loggedInUser = User(
      id: '1',
      username: 'test',
      email: email,
    );
    notifyListeners();
    return Future.value(_loggedInUser);
  }

  Future<User> login(String email, String password) {
    _loggedInUser = User(
      id: '1',
      username: 'test',
      email: email,
    );
    notifyListeners();
    return Future.value(_loggedInUser);
  }

  Future<void> tryAutoLogin() async {
    return Future.value();
  }

  Future<void> logout() async {
    _loggedInUser = null;
    notifyListeners();
    return Future.value();
  }
}
