import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../models/promotion.dart';
import '../../services/promotions_service.dart';

class PromotionsManager with ChangeNotifier {
  final PromotionsService _service = PromotionsService();
  List<Promotion> _items = [];

  List<Promotion> get items => [..._items];

  List<Promotion> get availableItems {
    final now = DateTime.now();
    return _items.where((p) => p.endDate.isAfter(now)).toList();
  }

  Future<void> fetchPromotions() async {
    _items = await _service.fetchPromotions();
    notifyListeners();
  }

  Future<void> addPromotion(Promotion promotion, {File? imageFile}) async {
    final newPromotion = await _service.addPromotion(promotion, imageFile: imageFile);
    if (newPromotion != null) {
      _items.insert(0, newPromotion);
      notifyListeners();
    }
  }

  Future<void> updatePromotion(Promotion promotion, {File? imageFile}) async {
    final index = _items.indexWhere((p) => p.id == promotion.id);
    if (index >= 0) {
      final updated = await _service.updatePromotion(promotion, imageFile: imageFile);
      if (updated != null) {
        _items[index] = updated;
        notifyListeners();
      }
    }
  }

  Future<void> deletePromotion(String id) async {
    final index = _items.indexWhere((p) => p.id == id);
    if (index >= 0) {
      final promotion = _items[index];
      _items.removeAt(index);
      notifyListeners();
      
      final success = await _service.deletePromotion(id);
      if (!success) {
        _items.insert(index, promotion);
        notifyListeners();
        throw Exception('Could not delete promotion');
      }
    }
  }
}
