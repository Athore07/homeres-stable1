// lib/data/repositories/booking_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../models/booking_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final FirebaseFirestore firestore;

  BookingRepositoryImpl({required this.firestore});

  @override
  Future<List<BookingEntity>> getUserBookings(String userId) async {
    final snapshot = await firestore
        .collection(FirebaseConstants.bookingsCollection)
        .where('homeownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<BookingEntity>> getTechnicianBookings(String technicianId) async {
    final snapshot = await firestore
        .collection(FirebaseConstants.bookingsCollection)
        .where('technicianId', isEqualTo: technicianId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
  }

  @override
  Future<BookingEntity> createBooking(BookingEntity booking) async {
    final docRef = firestore
        .collection(FirebaseConstants.bookingsCollection)
        .doc();
    final bookingModel = BookingModel(
      id: docRef.id,
      homeownerId: booking.homeownerId,
      technicianId: booking.technicianId,
      serviceId: booking.serviceId,
      serviceName: booking.serviceName,
      scheduledTime: booking.scheduledTime,
      status: BookingStatus.pending,
      address: booking.address,
      latitude: booking.latitude,
      longitude: booking.longitude,
      description: booking.description,
      totalPrice: booking.totalPrice,
      createdAt: DateTime.now(),
    );
    await docRef.set(bookingModel.toFirestore());
    return bookingModel;
  }

  @override
  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    await firestore
        .collection(FirebaseConstants.bookingsCollection)
        .doc(bookingId)
        .update({
          'status': status.name,
          if (status == BookingStatus.completed) 'completedAt': Timestamp.fromDate(DateTime.now()),
        });
  }

  @override
  Future<BookingEntity?> getBookingById(String bookingId) async {
    final doc = await firestore
        .collection(FirebaseConstants.bookingsCollection)
        .doc(bookingId)
        .get();
    if (!doc.exists) return null;
    return BookingModel.fromFirestore(doc);
  }
}