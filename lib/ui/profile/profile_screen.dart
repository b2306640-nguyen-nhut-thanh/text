import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../auth/auth_manager.dart';
import '../booking/bookings_manager.dart';
import '../shared/app_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthManager>().user;
    final bookings = context.watch<BookingsManager>().bookingCount;
    final hasAvatar = user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty;

    return Scaffold(
      appBar: AppHeader(
        title: const Text('Hồ sơ cá nhân'),
        actions: [
          IconButton(
            tooltip: 'Chỉnh sửa thông tin',
            onPressed: () => context.push('/profile/edit'),
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: () => context.go('/logout'),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary,
              backgroundImage: hasAvatar ? NetworkImage(user.avatarUrl!) : null,
              child: !hasAvatar
                  ? const Icon(Icons.person, size: 54, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.name ?? 'Traveler',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            user?.email ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton.icon(
              onPressed: () => context.push('/profile/edit'),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Thay đổi thông tin'),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Thông tin cá nhân',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Số điện thoại'),
                  subtitle: Text(
                    user?.phone?.isNotEmpty == true
                        ? user!.phone!
                        : 'Chưa cập nhật',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('Địa chỉ'),
                  subtitle: Text(
                    user?.address?.isNotEmpty == true
                        ? user!.address!
                        : 'Chưa cập nhật',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Ngày sinh'),
                  subtitle: Text(
                    user?.dob?.isNotEmpty == true
                        ? user!.dob!
                        : 'Chưa cập nhật',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (user?.isAdmin == true) ...[
            Text(
              'Quản trị viên',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              child: ListTile(
                leading: const Icon(Icons.edit_location_alt),
                title: const Text('Quản lý danh sách Tour'),
                subtitle: const Text('Thêm, sửa, xóa các tour du lịch'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push('/manage-tours'),
              ),
            ),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              child: ListTile(
                leading: const Icon(Icons.local_offer),
                title: const Text('Quản lý Khuyến mãi'),
                subtitle: const Text('Thêm, sửa, xóa các khuyến mãi'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push('/manage-promotions'),
              ),
            ),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              child: ListTile(
                leading: const Icon(Icons.event_available),
                title: const Text('Quản lý Booking'),
                subtitle: const Text('Xem và xác nhận đơn đặt tour'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push('/manage-bookings'),
              ),
            ),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              child: ListTile(
                leading: const Icon(Icons.place),
                title: const Text('Quản lý Địa điểm'),
                subtitle: const Text('Quản lý Điểm đến yêu thích (Home)'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push('/manage-destinations'),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            'Hoạt động',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.confirmation_number),
              title: const Text('Số booking đã đặt'),
              trailing: Text(
                '$bookings',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              onTap: () => context.go('/bookings'),
            ),
          ),
        ],
      ),
    );
  }
}