import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../notifications/notifications_manager.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final List<Widget>? actions;

  const AppHeader({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      actions: [
        if (actions != null) ...actions!,
        Consumer<NotificationsManager>(
          builder: (context, manager, _) {
            final unreadCount = manager.unreadCount;
            return IconButton(
              tooltip: 'Thông báo',
              onPressed: () {
                context.push('/notifications');
              },
              icon: Badge(
                isLabelVisible: unreadCount > 0,
                label: Text(unreadCount > 99 ? '99+' : unreadCount.toString()),
                child: const Icon(Icons.notifications_none),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}