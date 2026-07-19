import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'notifications_manager.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<NotificationsManager>();
    final notifications = manager.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          if (manager.unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Đánh dấu tất cả đã đọc',
              onPressed: () {
                manager.markAllAsRead();
              },
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text('Không có thông báo nào.'),
            )
          : ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return ListTile(
                  tileColor: notif.isRead
                      ? null
                      : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  leading: CircleAvatar(
                    backgroundColor: notif.isRead
                        ? Colors.grey.shade200
                        : Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.notifications,
                      color: notif.isRead
                          ? Colors.grey
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    notif.title,
                    style: TextStyle(
                      fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(notif.message),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(notif.created),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  onTap: () {
                    if (!notif.isRead) {
                      manager.markAsRead(notif.id);
                    }
                    if (notif.relatedId.isNotEmpty) {
                      // Nếu có liên kết tới booking, có thể điều hướng tới đó
                      context.push('/bookings/${notif.relatedId}');
                    }
                  },
                );
              },
            ),
    );
  }
}
