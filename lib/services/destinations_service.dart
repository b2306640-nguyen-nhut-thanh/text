import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../../models/destination.dart';
import 'database_helper.dart';
import 'pocketbase_client.dart';

class DestinationsService {
  final String _collectionName = 'destinations';
  final dbHelper = DatabaseHelper.instance;

  // Sync PocketBase to SQLite
  Future<void> _syncToSqlite(List<Destination> destinations) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete('destinations');
      for (final dest in destinations) {
        await txn.insert('destinations', dest.toJson());
      }
    });
  }

  // Lấy dữ liệu (Thử lấy từ PB trước, nếu lỗi thì lấy từ SQLite)
  Future<List<Destination>> fetchDestinations() async {
    try {
      final pb = await getPocketbaseInstance();
      final records = await pb.collection(_collectionName).getFullList(
        sort: 'created',
      );
      
      final destinations = records.map((r) => Destination.fromJson({
        ...r.toJson(),
        'id': r.id,
      })).toList();
      
      // Save cache to SQLite
      await _syncToSqlite(destinations);
      return destinations;
    } catch (e) {
      print('Lỗi lấy Destinations từ PocketBase, sử dụng SQLite cache: $e');
      final db = await dbHelper.database;
      final maps = await db.query('destinations');
      return maps.map((map) => Destination.fromJson(map)).toList();
    }
  }

  // Thêm Destination
  Future<Destination?> addDestination(Destination dest, {File? imageFile}) async {
    try {
      final pb = await getPocketbaseInstance();
      final body = {
        'title': dest.title,
        'region': dest.region,
      };

      final record = await pb.collection(_collectionName).create(
        body: body,
        files: imageFile != null
            ? [
                http.MultipartFile.fromBytes(
                  'image',
                  await imageFile.readAsBytes(),
                  filename: path.basename(imageFile.path),
                )
              ]
            : [],
      );

      final newDest = Destination.fromJson({
        ...record.toJson(),
        'id': record.id,
      });

      // Lưu vào SQLite
      final db = await dbHelper.database;
      await db.insert('destinations', newDest.toJson());
      
      return newDest;
    } catch (e) {
      print('Lỗi thêm Destination: $e');
      rethrow;
    }
  }

  // Cập nhật Destination
  Future<Destination?> updateDestination(Destination dest, {File? imageFile}) async {
    try {
      final pb = await getPocketbaseInstance();
      final body = {
        'title': dest.title,
        'region': dest.region,
      };

      final record = await pb.collection(_collectionName).update(
        dest.id,
        body: body,
        files: imageFile != null
            ? [
                http.MultipartFile.fromBytes(
                  'image',
                  await imageFile.readAsBytes(),
                  filename: imageFile.path.split('/').last,
                )
              ]
            : [],
      );

      final updatedDest = Destination.fromJson({
        ...record.toJson(),
        'id': record.id,
      });

      // Cập nhật SQLite
      final db = await dbHelper.database;
      await db.update(
        'destinations',
        updatedDest.toJson(),
        where: 'id = ?',
        whereArgs: [dest.id],
      );

      return updatedDest;
    } catch (e) {
      print('Lỗi cập nhật Destination: $e');
      rethrow;
    }
  }

  // Xóa Destination
  Future<bool> deleteDestination(String id) async {
    try {
      final pb = await getPocketbaseInstance();
      await pb.collection(_collectionName).delete(id);

      // Xóa trong SQLite
      final db = await dbHelper.database;
      await db.delete(
        'destinations',
        where: 'id = ?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      print('Lỗi xóa Destination: $e');
      rethrow;
    }
  }
}
