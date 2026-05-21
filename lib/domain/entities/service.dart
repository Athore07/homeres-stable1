
// lib/domain/entities/service.dart
class ServiceEntity {
  final String id;
  final String name;
  final String category;
  final String description;
  final String icon;
  final double basePrice;
  final bool isActive;
  final DateTime createdAt;

  const ServiceEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.icon,
    required this.basePrice,
    this.isActive = true,
    required this.createdAt,
  });
}