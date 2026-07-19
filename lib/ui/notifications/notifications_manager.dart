import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../models/notification.dart';
import '../../services/notifications_service.dart';
import '../auth/auth_manager.dart';

class NotificationsManager with ChangeNotifier {
  final NotificationsService _service = NotificationsService();
  final AuthManager _authManager;
  
  List<AppNotification> _notifications = [];
  Timer? _pollingTimer;

  NotificationsManager(this._authManager) {
    // Tự động tải thông báo khi Auth thay đổi
    _authManager.addListener(_onAuthChanged);
    _onAuthChanged(); // Tải lần đầu
  }

  void _onAuthChanged() {
    if (_authManager.isAuth) {
      fetchNotifications();
      // Bắt đầu polling (lấy dữ liệu mới mỗi 30s) vì PocketBase real-time qua SSE đôi khi cần setup thêm thư viện
      _pollingTimer?.cancel();
      _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        fetchNotifications();
      });
    } else {
      _notifications = [];
      _pollingTimer?.cancel();
      notifyListeners();
    }
  }

  List<AppNotification> get notifications => [..._notifications];
  
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications() async {
    if (!_authManager.isAuth) return;
    
    final userId = _authManager.user?.id;
    final isAdmin = _authManager.isAdmin;
    
    final fetched = await _service.fetchNotifications(
      userId: userId, 
      isAdmin: isAdmin
    );
    
    _notifications = fetched;
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index >= 0 && !_notifications[index].isRead) {
      // Optimistic update
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
      
      await _service.markAsRead(id);
    }
  }

  Future<void> markAllAsRead() async {
    final userId = _authManager.user?.id;
    final isAdmin = _authManager.isAdmin;
    
    // Optimistic update
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();

    await _service.markAllAsRead(userId: userId, isAdmin: isAdmin);
  }

  @override
  void dispose() {
    _authManager.removeListener(_onAuthChanged);
    _pollingTimer?.cancel();
    super.dispose();
  }
}
