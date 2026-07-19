class Promotion {
  final String id;
  final String title;
  final String imageFile;
  final DateTime endDate;

  Promotion({
    required this.id,
    required this.title,
    required this.imageFile,
    required this.endDate,
  });

  // Lấy ảnh hiển thị cuối cùng
  String getDisplayImageUrl(String pocketBaseUrl) {
    if (imageFile.isNotEmpty) {
      if (imageFile.startsWith('http')) return imageFile;
      if (pocketBaseUrl.isNotEmpty) {
        return '$pocketBaseUrl/api/files/promotions/$id/$imageFile';
      }
    }
    return 'https://placehold.co/600x400/e0e0e0/808080.png?text=No+Image';
  }

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      imageFile: json['image'] ?? json['imageFile'] ?? json['imageUrl'] ?? '',
      endDate: json['endDate'] != null && json['endDate'].toString().isNotEmpty
          ? DateTime.parse(json['endDate'])
          : DateTime.now().add(const Duration(days: 30)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageFile': imageFile,
      'endDate': endDate.toIso8601String(),
    };
  }

  Promotion copyWith({
    String? id,
    String? title,
    String? imageFile,
    DateTime? endDate,
  }) {
    return Promotion(
      id: id ?? this.id,
      title: title ?? this.title,
      imageFile: imageFile ?? this.imageFile,
      endDate: endDate ?? this.endDate,
    );
  }
}
