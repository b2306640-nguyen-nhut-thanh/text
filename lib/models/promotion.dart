class Promotion {
  final String id;
  final String title;
  final String imageUrl;
  final String imageFile; // Tên file được lưu trên PocketBase
  final DateTime endDate;

  Promotion({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.imageFile,
    required this.endDate,
  });

  // Lấy ảnh hiển thị cuối cùng
  String getDisplayImageUrl(String pocketBaseUrl) {
    if (imageFile.isNotEmpty && pocketBaseUrl.isNotEmpty) {
      // PocketBase format: /api/files/{collectionId}/{recordId}/{filename}
      return '$pocketBaseUrl/api/files/promotions/$id/$imageFile';
    }
    return imageUrl;
  }

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      imageFile: json['image'] ?? '', // Cột trên PocketBase tên là 'image'
      endDate: json['endDate'] != null && json['endDate'].toString().isNotEmpty
          ? DateTime.parse(json['endDate'])
          : DateTime.now().add(const Duration(days: 30)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'endDate': endDate.toIso8601String(),
    };
  }

  Promotion copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? imageFile,
    DateTime? endDate,
  }) {
    return Promotion(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      imageFile: imageFile ?? this.imageFile,
      endDate: endDate ?? this.endDate,
    );
  }
}
