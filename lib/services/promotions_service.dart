import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/promotion.dart';
import 'pocketbase_client.dart';

class PromotionsService {
  Future<List<Promotion>> fetchPromotions() async {
    final List<Promotion> promotions = [];
    try {
      final pb = await getPocketbaseInstance();
      final records = await pb.collection('promotions').getFullList(
            sort: '-created',
          );

      for (final record in records) {
        try {
          promotions.add(
            Promotion.fromJson({
              ...record.toJson(),
              'id': record.id,
            }),
          );
        } catch (e) {
          print('Lỗi đọc promotion: $e');
        }
      }
      return promotions;
    } catch (e) {
      print('Lỗi fetch promotions từ PocketBase: $e');
      return promotions;
    }
  }

  Future<Promotion?> addPromotion(Promotion promotion, {File? imageFile}) async {
    try {
      final pb = await getPocketbaseInstance();
      final body = promotion.toJson();
      body.remove('id');
      body.remove('imageFile');
      body.removeWhere((key, value) => value == null);

      List<http.MultipartFile> files = [];
      if (imageFile != null) {
        files.add(
          await http.MultipartFile.fromPath('imageFile', imageFile.path),
        );
      }

      final record = await pb.collection('promotions').create(
            body: body,
            files: files,
          );

      return Promotion.fromJson({
        ...record.toJson(),
        'id': record.id,
      });
    } catch (e) {
      print('Lỗi thêm promotion: $e');
      return null;
    }
  }

  Future<Promotion?> updatePromotion(Promotion promotion, {File? imageFile}) async {
    try {
      final pb = await getPocketbaseInstance();
      final body = promotion.toJson();
      body.remove('id');
      body.remove('imageFile');
      body.removeWhere((key, value) => value == null);

      List<http.MultipartFile> files = [];
      if (imageFile != null) {
        files.add(
          await http.MultipartFile.fromPath('imageFile', imageFile.path),
        );
      }

      final record = await pb.collection('promotions').update(
            promotion.id,
            body: body,
            files: files,
          );

      return Promotion.fromJson({
        ...record.toJson(),
        'id': record.id,
      });
    } catch (e) {
      print('Lỗi cập nhật promotion: $e');
      return null;
    }
  }

  Future<bool> deletePromotion(String id) async {
    try {
      final pb = await getPocketbaseInstance();
      await pb.collection('promotions').delete(id);
      return true;
    } catch (e) {
      print('Lỗi xóa promotion: $e');
      return false;
    }
  }
}
