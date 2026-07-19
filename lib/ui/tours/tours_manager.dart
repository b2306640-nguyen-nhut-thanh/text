import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../models/tour.dart';
import '../../services/tours_service.dart';
import '../../services/favorites_service.dart';

class ToursManager with ChangeNotifier {
  final ToursService _toursService = ToursService();
  final FavoritesService _favoritesService = FavoritesService();
  List<Tour> _items = [];
  Set<String> _favoriteTourIds = {};

  List<Tour> get items => [..._items];
  
  List<Tour> get availableItems {
    final now = DateTime.now();
    return _items.where((t) {
      if (t.isSoldOut) return false;
      if (t.departureDate != null && t.departureDate!.isBefore(now)) return false;
      return true;
    }).toList();
  }

  List<Tour> get favoriteItems =>
      _items.where((tour) => _favoriteTourIds.contains(tour.id)).toList();
      
  bool isFavorite(String id) => _favoriteTourIds.contains(id);

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
    _favoriteTourIds = await _favoritesService.fetchFavoriteTourIds();
    notifyListeners();
  }

  Future<void> addTour(Tour tour, {File? imageFile}) async {
    final newTour = await _toursService.addTour(tour, imageFile: imageFile);
    if (newTour != null) {
      _items.insert(0, newTour);
      notifyListeners();
    }
  }

  Future<void> updateTour(Tour tour, {File? imageFile}) async {
    final index = _items.indexWhere((item) => item.id == tour.id);
    if (index < 0) {
      return;
    }
    
    final updatedTour = await _toursService.updateTour(tour, imageFile: imageFile);
    if (updatedTour != null) {
      _items[index] = updatedTour;
      notifyListeners();
    }
  }

  Future<void> deleteTour(String id) async {
    final success = await _toursService.deleteTour(id);
    if (success) {
      _items.removeWhere((tour) => tour.id == id);
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String id) async {
    final index = _items.indexWhere((tour) => tour.id == id);
    if (index < 0) return;
    
    final tour = _items[index];
    final bool willBeFavorite = !_favoriteTourIds.contains(id);

    // Cập nhật UI ngay lập tức
    if (willBeFavorite) {
      _favoriteTourIds.add(id);
    } else {
      _favoriteTourIds.remove(id);
    }
    notifyListeners();

    // Đồng bộ lên server
    if (willBeFavorite) {
      await _favoritesService.addFavorite(id);
    } else {
      await _favoritesService.removeFavorite(id);
    }
  }
}