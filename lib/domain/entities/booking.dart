// lib/domain/entities/booking.dart
enum BookingStatus { pending, accepted, inProgress, completed, cancelled }

class BookingEntity {
  final String id;
  final String homeownerId;
  final String technicianId;
  final String serviceId;
  final String serviceName;
  final DateTime scheduledTime;
  final BookingStatus status;
  final String address;
  final double latitude;
  final double longitude;
  final String description;
  final double totalPrice;
  final DateTime createdAt;
  final DateTime? completedAt;

  const BookingEntity({
    required this.id,
    required this.homeownerId,
    required this.technicianId,
    required this.serviceId,
    required this.serviceName,
    required this.scheduledTime,
    required this.status,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.totalPrice,
    required this.createdAt,
    this.completedAt,
  });
}