class AppUser {
  final String id;
  final String name;
  final String email;
  final bool isAdmin;
  final String? phone;
  final String? address;
  final String? dob;
  final String? avatarUrl;

  const AppUser({
    this.id = '',
    required this.name,
    required this.email,
    this.isAdmin = false,
    this.phone,
    this.address,
    this.dob,
    this.avatarUrl,
  });

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    bool? isAdmin,
    String? phone,
    String? address,
    String? dob,
    String? avatarUrl,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isAdmin: isAdmin ?? this.isAdmin,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      dob: dob ?? this.dob,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'isAdmin': isAdmin,
      'phone': phone,
      'address': address,
      'dob': dob,
      'avatarUrl': avatarUrl,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
      phone: json['phone'],
      address: json['address'],
      dob: json['dob'],
      avatarUrl: json['avatarUrl'],
    );
  }
}