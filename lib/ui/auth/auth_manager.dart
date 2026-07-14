import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';

class AuthManager with ChangeNotifier {
  late final AuthService _authService;
  AppUser? _user;

  AuthManager() {
    // 1. CẬP NHẬT: Lắng nghe sự thay đổi trạng thái từ PocketBase (chuản theo MyShop)
    // Khi token hết hạn hoặc có thay đổi user, UI sẽ tự động cập nhật
    _authService = AuthService(
      onAuthChange: (user) {
        _user = user;
        notifyListeners();
      },
    );
  }

  bool get isAuth => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  AppUser? get user => _user;

  // 2. THÊM MỚI: Hàm đăng ký tài khoản (dành cho màn hình Đăng ký)
  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required String passwordConfirm,
  }) async {
    _user = await _authService.signup(
      name: name,
      email: email,
      password: password,
      passwordConfirm: passwordConfirm,
    );
    notifyListeners();
  }

  // 3. Đăng nhập
  Future<void> login(String email, String password) async {
    _user = await _authService.login(email, password);
    notifyListeners();
  }

  // 4. CẬP NHẬT: Tự động đăng nhập từ bộ nhớ PocketBase (thay cho tryAutoLogin cũ)
  Future<void> tryAutoLogin() async {
    _user = await _authService.getUserFromStore();
    notifyListeners();
  }

  // 5. Đăng xuất
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  // 6. Cập nhật Profile
  Future<void> updateProfile(AppUser updatedUser) async {
    _user = await _authService.updateProfile(updatedUser);
    notifyListeners();
  }
}