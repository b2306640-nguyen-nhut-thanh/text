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
    final newTour = await _toursService.addTour(tour);
    if (newTour != null) {
      _items.insert(0, newTour);
      notifyListeners();
    }
  }

  Future<void> updateTour(Tour tour) async {
    final index = _items.indexWhere((item) => item.id == tour.id);
    if (index < 0) {
      return;
    }
    
    final updatedTour = await _toursService.updateTour(tour);
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
    final tour = findById(id);
    if (tour == null) {
      return;
    }
    await updateTour(tour.copyWith(isFavorite: !tour.isFavorite));
  }
}