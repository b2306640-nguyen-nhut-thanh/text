import 'package:flutter/foundation.dart';

import '../../models/tour.dart';
import '../../services/tours_service.dart';

class ToursManager with ChangeNotifier {
  final ToursService _toursService = ToursService();
  List<Tour> _items = [];

  List<Tour> get items => [..._items];
  List<Tour> get favoriteItems =>
      _items.where((tour) => tour.isFavorite).toList();
  int get itemCount => _items.length;

  Tour? findById(String id) {
    try {
      return _items.firstWhere((tour) => tour.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> fetchTours() async {
    _items = await _toursService.fetchTours();
    notifyListeners();
  }

  Future<void> addTour(Tour tour) async {
    _items.add(tour);
    await _toursService.saveTours(_items);
    notifyListeners();
  }

  Future<void> updateTour(Tour tour) async {
    final index = _items.indexWhere((item) => item.id == tour.id);
    if (index < 0) {
      return;
    }
    _items[index] = tour;
    await _toursService.saveTours(_items);
    notifyListeners();
  }

  Future<void> deleteTour(String id) async {
    _items.removeWhere((tour) => tour.id == id);
    await _toursService.saveTours(_items);
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    final tour = findById(id);
    if (tour == null) {
      return;
    }
    await updateTour(tour.copyWith(isFavorite: !tour.isFavorite));
  }
}
