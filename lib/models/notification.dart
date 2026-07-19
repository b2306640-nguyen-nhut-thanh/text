class AppNotification {
  final String id;
  final String userId;
  final bool forAdmin;
  final String title;
  final String message;
  final bool isRead;
  final String type;
  final String relatedId;
  final DateTime created;

  AppNotification({
    required this.id,
    required this.userId,
    required this.forAdmin,
    required this.title,
    required this.message,
    required this.isRead,
    required this.type,
    required this.relatedId,
    required this.created,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      forAdmin: json['forAdmin'] ?? false,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['isRead'] ?? false,
      type: json['type'] ?? '',
      relatedId: json['relatedId'] ?? '',
      created: json['created'] != null
          ? DateTime.parse(json['created'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'forAdmin': forAdmin,
      'title': title,
      'message': message,
      'isRead': isRead,
      'type': type,
      'relatedId': relatedId,
    };
  }

  AppNotification copyWith({
    String? id,
    String? userId,
    bool? forAdmin,
    String? title,
    String? message,
    bool? isRead,
    String? type,
    String? relatedId,
    DateTime? created,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      forAdmin: forAdmin ?? this.forAdmin,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
      created: created ?? this.created,
    );
  }
}
