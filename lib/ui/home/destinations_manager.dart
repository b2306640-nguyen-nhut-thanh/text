import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../models/destination.dart';
import '../../services/destinations_service.dart';

class DestinationsManager with ChangeNotifier {
  final DestinationsService _service = DestinationsService();
  List<Destination> _items = [];

  List<Destination> get items => [..._items];
  
  List<String> get regions {
    return _items.map((e) => e.region).toSet().toList()..sort();
  }

  List<Destination> getDestinationsByRegion(String region) {
    return _items.where((e) => e.region == region).toList();
  }

  Future<void> fetchDestinations() async {
    _items = await _service.fetchDestinations();
    notifyListeners();
  }

  Future<void> addDestination(Destination dest, {File? imageFile}) async {
    final newDest = await _service.addDestination(dest, imageFile: imageFile);
    if (newDest != null) {
      _items.add(newDest);
      notifyListeners();
    }
  }

  Future<void> updateDestination(Destination dest, {File? imageFile}) async {
    final index = _items.indexWhere((e) => e.id == dest.id);
    if (index >= 0) {
      final updated = await _service.updateDestination(dest, imageFile: imageFile);
      if (updated != null) {
        _items[index] = updated;
        notifyListeners();
      }
    }
  }

  Future<void> deleteDestination(String id) async {
    final success = await _service.deleteDestination(id);
    if (success) {
      _items.removeWhere((e) => e.id == id);
      notifyListeners();
    }
  }
}
