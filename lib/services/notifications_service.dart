import 'package:pocketbase/pocketbase.dart';
import '../models/notification.dart';
import 'pocketbase_client.dart';

class NotificationsService {

  Future<List<AppNotification>> fetchNotifications({String? userId, bool isAdmin = false}) async {
    try {
      String filter = '';
      if (isAdmin) {
        filter = 'forAdmin = true';
      } else if (userId != null && userId.isNotEmpty) {
        filter = 'userId = "$userId"';
      } else {
        return [];
      }

      final pb = await getPocketbaseInstance();
      final records = await pb.collection('notifications').getList(
        filter: filter,
        sort: '-created',
        perPage: 50,
      );
      
      return records.items.map((r) => AppNotification.fromJson({
        ...r.toJson(),
        'id': r.id,
        'created': r.created,
      })).toList();
    } catch (e) {
      print('Lỗi tải thông báo: $e');
      return [];
    }
  }

  Future<AppNotification?> createNotification(AppNotification notification) async {
    try {
      final body = notification.toJson();
      if (body['userId'] == '') {
        body.remove('userId');
      }
      
      final pb = await getPocketbaseInstance();
      final record = await pb.collection('notifications').create(body: body);
      return AppNotification.fromJson({
        ...record.toJson(),
        'id': record.id,
        'created': record.created,
      });
    } catch (e) {
      print('Lỗi tạo thông báo: $e');
      return null;
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final pb = await getPocketbaseInstance();
      await pb.collection('notifications').update(id, body: {'isRead': true});
    } catch (e) {
      print('Lỗi cập nhật trạng thái đã đọc: $e');
    }
  }

  Future<void> markAllAsRead({String? userId, bool isAdmin = false}) async {
    try {
      // Vì PocketBase không hỗ trợ update nhiều record cùng lúc qua API
      // Nên chúng ta sẽ lấy danh sách chưa đọc và update từng cái
      String filter = 'isRead = false';
      if (isAdmin) {
        filter += ' && forAdmin = true';
      } else if (userId != null && userId.isNotEmpty) {
        filter += ' && userId = "$userId"';
      } else {
        return;
      }

      final pb = await getPocketbaseInstance();
      final records = await pb.collection('notifications').getFullList(filter: filter);
      for (var record in records) {
        await markAsRead(record.id);
      }
    } catch (e) {
      print('Lỗi markAllAsRead: $e');
    }
  }
}
