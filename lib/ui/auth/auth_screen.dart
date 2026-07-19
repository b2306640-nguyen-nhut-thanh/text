import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_manager.dart';

// 1. THÊM MỚI: Enum quản lý trạng thái màn hình
enum AuthMode { login, register }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  AuthMode _authMode = AuthMode.login;

  // Bỏ giá trị mặc định cứng để form sạch sẽ
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  var _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Tối ưu UX: Clear lỗi và dữ liệu xác nhận khi đổi chế độ Đăng nhập <-> Đăng ký
  void _switchAuthMode() {
    setState(() {
      _authMode = _authMode == AuthMode.login
          ? AuthMode.register
          : AuthMode.login;
      _confirmPasswordController.clear();
      if (_authMode == AuthMode.register) {
        _nameController.clear();
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);

    final authManager = context.read<AuthManager>();
    try {
      if (_authMode == AuthMode.login) {
        await authManager.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        await authManager.signup(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          passwordConfirm: _confirmPasswordController.text.trim(),
        );
        // Hiển thị thông báo chào mừng khi đăng ký & auto-login thành công
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Chào mừng ${_nameController.text.trim()} đến với TravelMate!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.toString().replaceAll('Exception: ', ''),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = _authMode == AuthMode.login;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.flight_takeoff,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    // Đổi tiêu đề động theo chế độ
                    isLogin ? 'Đăng Nhập Travol' : 'Tạo Tài Khoản Mới',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // --- PHẦN 1: TRƯỜNG HỌ VÀ TÊN (Chỉ hiện khi Đăng ký) ---
                            if (!isLogin) ...[
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Họ và tên',
                                  prefixIcon: Icon(Icons.person),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Vui lòng nhập họ tên';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                            ],

                            // --- PHẦN 2: TRƯỜNG EMAIL ---
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email),
                              ),
                              validator: (value) {
                                if (value == null || !value.contains('@')) {
                                  return 'Nhập email hợp lệ';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // --- PHẦN 3: TRƯỜNG MẬT KHẨU ---
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Mật khẩu',
                                prefixIcon: Icon(Icons.lock),
                              ),
                              validator: (value) {
                                // Mặc định của PocketBase yêu cầu mật khẩu từ 8 ký tự
                                if (value == null || value.length < 8) {
                                  return 'Mật khẩu tối thiểu 8 ký tự';
                                }
                                return null;
                              },
                            ),

                            // --- PHẦN 4: TRƯỜNG XÁC NHẬN MẬT KHẨU (Chỉ hiện khi Đăng ký) ---
                            if (!isLogin) ...[
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Xác nhận mật khẩu',
                                  prefixIcon: Icon(Icons.lock_outline),
                                ),
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return 'Mật khẩu xác nhận không khớp';
                                  }
                                  return null;
                                },
                              ),
                            ],
                            const SizedBox(height: 20),

                            // --- PHẦN 5: NÚT ĐĂNG NHẬP / ĐĂNG KÝ ---
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _isLoading ? null : _submit,
                                icon: _isLoading
                                    ? const SizedBox.square(
                                        dimension: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(
                                        isLogin
                                            ? Icons.login
                                            : Icons.person_add,
                                      ),
                                label: Text(isLogin ? 'Đăng nhập' : 'Đăng ký'),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // --- PHẦN 6: NÚT CHUYỂN ĐỔI CHẾ ĐỘ ---
                            TextButton(
                              onPressed: _isLoading ? null : _switchAuthMode,
                              child: Text(
                                isLogin
                                    ? 'Chưa có tài khoản? Đăng ký ngay'
                                    : 'Đã có tài khoản? Đăng nhập',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
