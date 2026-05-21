// lib/data/models/service_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/service.dart';

class ServiceModel extends ServiceEntity {
  const ServiceModel({
    required super.id,
    required super.name,
    required super.category,
    required super.description,
    required super.icon,
    required super.basePrice,
    super.isActive = true,
    required super.createdAt,
  });

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'] ?? 'build',
      basePrice: (data['basePrice'] ?? 0).toDouble(),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'category': category,
    'description': description,
    'icon': icon,
    'basePrice': basePrice,
    'isActive': isActive,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}