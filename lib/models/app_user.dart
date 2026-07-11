class AppUser {
  final String name;
  final String email;
  final bool isAdmin;
  final String? phone;
  final String? address;
  final String? dob; // Ngày sinh (ví dụ: dd/MM/yyyy)
  final String? avatarUrl;

  const AppUser({
    required this.name,
    required this.email,
    this.isAdmin = false,
    this.phone,
    this.address,
    this.dob,
    this.avatarUrl,
  });

  AppUser copyWith({
    String? name,
    String? email,
    bool? isAdmin,
    String? phone,
    String? address,
    String? dob,
    String? avatarUrl,
  }) {
    return AppUser(
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