// lib/data/models/booking_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/booking.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.homeownerId,
    required super.technicianId,
    required super.serviceId,
    required super.serviceName,
    required super.scheduledTime,
    required super.status,
    required super.address,
    required super.latitude,
    required super.longitude,
    required super.description,
    required super.totalPrice,
    required super.createdAt,
    super.completedAt,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      homeownerId: data['homeownerId'] ?? '',
      technicianId: data['technicianId'] ?? '',
      serviceId: data['serviceId'] ?? '',
      serviceName: data['serviceName'] ?? '',
      scheduledTime: (data['scheduledTime'] as Timestamp).toDate(),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'pending'),
        orElse: () => BookingStatus.pending,
      ),
      address: data['address'] ?? '',
      latitude: (data['location'] as GeoPoint?)?.latitude ?? 0.0,
      longitude: (data['location'] as GeoPoint?)?.longitude ?? 0.0,
      description: data['description'] ?? '',
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null 
        ? (data['completedAt'] as Timestamp).toDate() 
        : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'homeownerId': homeownerId,
    'technicianId': technicianId,
    'serviceId': serviceId,
    'serviceName': serviceName,
    'scheduledTime': Timestamp.fromDate(scheduledTime),
    'status': status.name,
    'address': address,
    'location': GeoPoint(latitude, longitude),
    'description': description,
    'totalPrice': totalPrice,
    'createdAt': Timestamp.fromDate(createdAt),
    'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
  };
}