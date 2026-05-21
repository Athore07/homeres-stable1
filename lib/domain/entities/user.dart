// lib/domain/entities/user.dart
class UserEntity {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String role; // 'homeowner', 'technician', 'admin'
  final String? profileImage;
  final bool isVerified;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    required this.role,
    this.profileImage,
    this.isVerified = false,
    required this.createdAt,
  });

  bool get isHomeowner => role == 'homeowner';
  bool get isTechnician => role == 'technician';
  bool get isAdmin => role == 'admin';
  
  // Factory for creating a mock/guest user
  factory UserEntity.guest() => UserEntity(
    id: 'guest',
    email: 'guest@homeres.com',
    name: 'Guest User',
    role: 'homeowner',
    createdAt: DateTime.now(),
  );
  
  // Factory for creating from JSON (Firebase)
  factory UserEntity.fromJson(Map<String, dynamic> json) => UserEntity(
    id: json['id'] ?? '',
    email: json['email'] ?? '',
    name: json['name'] ?? '',
    phone: json['phone'],
    role: json['role'] ?? 'homeowner',
    profileImage: json['profileImage'],
    isVerified: json['isVerified'] ?? false,
    createdAt: json['createdAt'] is DateTime 
        ? json['createdAt'] 
        : DateTime.parse(json['createdAt']?.toString() ?? DateTime.now().toIso8601String()),
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'phone': phone,
    'role': role,
    'profileImage': profileImage,
    'isVerified': isVerified,
    'createdAt': createdAt.toIso8601String(),
  };
  
  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? role,
    String? profileImage,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}