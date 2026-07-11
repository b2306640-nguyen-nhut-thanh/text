import '../models/tour.dart';
import 'travel_storage_service.dart';

class ToursService {
  static const _storageKey = 'travel_tours';
  final TravelStorageService _storage = TravelStorageService();

  Future<List<Tour>> fetchTours() async {
    final storedTours = await _storage.readList(_storageKey);
    if (storedTours.isEmpty) {
      final seededTours = _seedTours();
      await saveTours(seededTours);
      return seededTours;
    }
    return storedTours.map(Tour.fromJson).toList();
  }

  Future<void> saveTours(List<Tour> tours) async {
    await _storage.writeList(
      _storageKey,
      tours.map((tour) => tour.toJson()).toList(),
    );
  }

  List<Tour> _seedTours() {
    return const [
      Tour(
        id: 't1',
        title: 'Da Nang Coastal Escape',
        location: 'Da Nang',
        description:
            'Khám phá biển Mỹ Khê, bán đảo Sơn Trà, Hội An về đêm và ẩm thực miền Trung trong lịch trình cân bằng giữa nghỉ dưỡng và trải nghiệm.',
        imageUrl:
            'https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?auto=format&fit=crop&w=1200&q=80',
        price: 3490000,
        durationDays: 3,
        rating: 4.8,
        isFavorite: true,
        highlights: ['Biển Mỹ Khê', 'Hội An', 'Bà Nà Hills'],
      ),
      Tour(
        id: 't2',
        title: 'Ha Long Bay Discovery',
        location: 'Quang Ninh',
        description:
            'Du thuyền trên vịnh Hạ Long, chèo kayak, thăm hang động và dùng bữa tối hải sản trên tàu.',
        imageUrl:
            'https://images.unsplash.com/photo-1528127269322-539801943592?auto=format&fit=crop&w=1200&q=80',
        price: 4290000,
        durationDays: 2,
        rating: 4.7,
        highlights: ['Du thuyền', 'Kayak', 'Hang Sửng Sốt'],
      ),
      Tour(
        id: 't3',
        title: 'Sapa Mountain Retreat',
        location: 'Lao Cai',
        description:
            'Trekking bản Cát Cát, săn mây Fansipan, thưởng thức đặc sản Tây Bắc và nghỉ tại homestay địa phương.',
        imageUrl:
            'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80',
        price: 3890000,
        durationDays: 3,
        rating: 4.6,
        highlights: ['Fansipan', 'Trekking', 'Homestay'],
      ),
      Tour(
        id: 't4',
        title: 'Phu Quoc Island Break',
        location: 'Kien Giang',
        description:
            'Nghỉ dưỡng tại đảo ngọc, lặn ngắm san hô, ngắm hoàng hôn Sunset Town và khám phá chợ đêm.',
        imageUrl:
            'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=80',
        price: 5290000,
        durationDays: 4,
        rating: 4.9,
        isFavorite: true,
        highlights: ['Lặn san hô', 'Sunset Town', 'Chợ đêm'],
      ),
    ];
  }
}
