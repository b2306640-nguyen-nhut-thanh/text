class Destination {
  final String id;
  final String title;
  final String region;
  final String imageFile;

  Destination({
    required this.id,
    required this.title,
    required this.region,
    required this.imageFile,
  });

  String getDisplayImageUrl(String pocketBaseUrl) {
    if (imageFile.isNotEmpty && pocketBaseUrl.isNotEmpty) {
      return '$pocketBaseUrl/api/files/destinations/$id/$imageFile';
    }
    return ''; // Placeholder or empty if no image
  }

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      region: json['region'] ?? '',
      imageFile: json['image'] ?? json['imageFile'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'region': region,
      'imageFile': imageFile, // Use internally for sqlite
    };
  }

  Destination copyWith({
    String? id,
    String? title,
    String? region,
    String? imageFile,
  }) {
    return Destination(
      id: id ?? this.id,
      title: title ?? this.title,
      region: region ?? this.region,
      imageFile: imageFile ?? this.imageFile,
    );
  }
}
