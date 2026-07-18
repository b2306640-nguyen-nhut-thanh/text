import 'package:pocketbase/pocketbase.dart';
import 'pocketbase_client.dart';

class FavoritesService {
  final String _collectionName = 'favorites';

  Future<Set<String>> fetchFavoriteTourIds() async {
    try {
      final pb = await getPocketbaseInstance();
      final user = pb.authStore.record;
      if (user == null) return {};

      final records = await pb.collection(_collectionName).getFullList(
        filter: 'userId = "${user.id}"',
      );

      return records.map((r) => r.getStringValue('tourId')).toSet();
    } catch (e) {
      print('Lỗi lấy danh sách yêu thích: $e');
      return {};
    }
  }

  Future<void> addFavorite(String tourId) async {
    try {
      final pb = await getPocketbaseInstance();
      final user = pb.authStore.record;
      if (user == null) return;

      await pb.collection(_collectionName).create(body: {
        'userId': user.id,
        'tourId': tourId,
      });
    } catch (e) {
      print('Lỗi thêm yêu thích: $e');
    }
  }

  Future<void> removeFavorite(String tourId) async {
    try {
      final pb = await getPocketbaseInstance();
      final user = pb.authStore.record;
      if (user == null) return;

      // Tìm bản ghi tương ứng để xóa
      final records = await pb.collection(_collectionName).getFullList(
        filter: 'userId = "${user.id}" && tourId = "$tourId"',
      );

      for (var record in records) {
        await pb.collection(_collectionName).delete(record.id);
      }
    } catch (e) {
      print('Lỗi xóa yêu thích: $e');
    }
  }
}
