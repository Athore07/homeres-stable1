// lib/data/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.phone,
    required super.role,
    super.profileImage,
    super.isVerified = false,
    required super.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'],
      role: data['role'] ?? 'homeowner',
      profileImage: data['profileImage'],
      isVerified: data['isVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'profileImage': profileImage,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      phone: entity.phone,
      role: entity.role,
      profileImage: entity.profileImage,
      isVerified: entity.isVerified,
      createdAt: entity.createdAt,
    );
  }
}