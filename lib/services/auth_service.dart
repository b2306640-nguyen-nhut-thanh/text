import 'package:pocketbase/pocketbase.dart';
import '../models/app_user.dart';
import 'pocketbase_client.dart';

class AuthService {
  void Function(AppUser? user)? onAuthChange;

  AuthService({this.onAuthChange}) {
    if (onAuthChange != null) {
      getPocketbaseInstance().then((pb) {
        pb.authStore.onChange.listen((event) {
          onAuthChange!(
            event.record == null ? null : AppUser.fromJson(event.record!.toJson()),
          );
        });
      });
    }
  }

  Future<AppUser> signup({
    required String name,
    required String email,
    required String password,
    required String passwordConfirm,
  }) async {
    final pb = await getPocketbaseInstance();
    try {
      await pb.collection('users').create(
        body: {
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
          'passwordConfirm': passwordConfirm,
          'isAdmin': false,
        },
      );
      
      return await login(email, password);
    } catch (error) {
      if (error is ClientException) {
        throw Exception(error.response['message'] ?? 'Lỗi khi đăng ký tài khoản');
      }
      throw Exception("Đã xảy ra lỗi hệ thống, vui lòng thử lại!");
    }
  }

  Future<AppUser> login(String email, String password) async {
    final pb = await getPocketbaseInstance();
    try {
      final authRecord = await pb
          .collection('users')
          .authWithPassword(email.trim(), password);
      return AppUser.fromJson(authRecord.record.toJson());
    } catch (error) {
      if (error is ClientException) {
        throw Exception(error.response['message'] ?? 'Email hoặc mật khẩu không đúng');
      }
      throw Exception("Đã xảy ra lỗi kết nối!");
    }
  }

  Future<AppUser?> getUserFromStore() async {
    final pb = await getPocketbaseInstance();
    final model = pb.authStore.record;
    if (model == null) {
      return null;
    }
    return AppUser.fromJson(model.toJson());
  }

  Future<void> logout() async {
    final pb = await getPocketbaseInstance();
    pb.authStore.clear();
  }

  Future<AppUser> updateProfile(AppUser updatedUser) async {
    final pb = await getPocketbaseInstance();
    try {
      final userId = pb.authStore.record!.id;
      final record = await pb.collection('users').update(
            userId,
            body: updatedUser.toJson(),
          );
      return AppUser.fromJson(record.toJson());
    } catch (error) {
      if (error is ClientException) {
        throw Exception(error.response['message'] ?? 'Không thể cập nhật hồ sơ');
      }
      throw Exception("Đã xảy ra lỗi khi lưu thông tin");
    }
  }
}