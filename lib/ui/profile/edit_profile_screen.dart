import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/app_user.dart';
import '../auth/auth_manager.dart';
import '../shared/app_header.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _dobController;
  late final TextEditingController _avatarController;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthManager>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _dobController = TextEditingController(text: user?.dob ?? '');
    _avatarController = TextEditingController(text: user?.avatarUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authManager = context.read<AuthManager>();
    final currentUser = authManager.user;
    if (currentUser == null) return;

    final updatedUser = currentUser.copyWith(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      dob: _dobController.text.trim(),
      avatarUrl: _avatarController.text.trim(),
    );

    await authManager.updateProfile(updatedUser);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật hồ sơ thành công!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: Text('Chỉnh sửa hồ sơ')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(
              controller: _nameController,
              label: 'Họ và tên',
              icon: Icons.person,
              required: true,
            ),
            _buildTextField(
              controller: _phoneController,
              label: 'Số điện thoại',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            _buildTextField(
              controller: _addressController,
              label: 'Địa chỉ',
              icon: Icons.location_on,
              maxLines: 2,
            ),
            _buildTextField(
              controller: _dobController,
              label: 'Ngày sinh (dd/MM/yyyy)',
              icon: Icons.calendar_today,
            ),
            _buildTextField(
              controller: _avatarController,
              label: 'URL Ảnh đại diện',
              icon: Icons.image,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save),
              label: const Text('Lưu thay đổi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (required && (value == null || value.trim().isEmpty)) {
            return 'Vui lòng nhập $label';
          }
          return null;
        },
      ),
    );
  }
}