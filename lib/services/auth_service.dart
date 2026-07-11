import '../models/app_user.dart';
import 'travel_storage_service.dart';

class AuthService {
  static const _authKey = 'travel_is_auth';
  static const _userKey = 'travel_user';
  static const _adminEmail = 'admin@travel.com';
  static const _adminPassword = 'admin123';
  final TravelStorageService _storage = TravelStorageService();

  Future<AppUser?> tryAutoLogin() async {
    final isAuth = await _storage.readBool(_authKey);
    if (!isAuth) {
      return null;
    }
    final user = await _storage.readMap(_userKey);
    return user == null ? null : AppUser.fromJson(user);
  }

  Future<AppUser> login(String email, String password) async {
    final normalizedEmail = email.toLowerCase();
    final isAdmin =
        normalizedEmail == _adminEmail && password == _adminPassword;
    final user = AppUser(
      name: normalizedEmail.split('@').first,
      email: normalizedEmail,
      isAdmin: isAdmin,
    );
    await _storage.writeBool(_authKey, true);
    await _storage.writeMap(_userKey, user.toJson());
    return user;
  }

  Future<void> logout() async {
    await _storage.writeBool(_authKey, false);
  }

  Future<AppUser> updateProfile(AppUser updatedUser) async {
    await _storage.writeMap(_userKey, updatedUser.toJson());
    return updatedUser;
  }
}
