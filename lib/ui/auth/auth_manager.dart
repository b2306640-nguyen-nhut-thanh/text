import 'package:flutter/foundation.dart';

import '../../models/app_user.dart';
import '../../services/auth_service.dart';

class AuthManager with ChangeNotifier {
  final AuthService _authService = AuthService();
  AppUser? _user;

  bool get isAuth => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  AppUser? get user => _user;

  Future<void> tryAutoLogin() async {
    _user = await _authService.tryAutoLogin();
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _user = await _authService.login(email, password);
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  Future<void> updateProfile(AppUser updatedUser) async {
    _user = await _authService.updateProfile(updatedUser);
    notifyListeners();
  }
}
