// lib/data/datasources/remote/booking_remote_datasource.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../models/booking_model.dart';

abstract class BookingRemoteDataSource {
  Stream<List<BookingModel>> watchUserBookings(String userId);
  Stream<List<BookingModel>> watchTechnicianBookings(String technicianId);
  Stream<BookingModel?> watchBooking(String bookingId);
  Future<void> createBooking(BookingModel booking);
  Future<void> updateStatus(String bookingId, String status);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final FirebaseFirestore firestore;

  BookingRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<BookingModel>> watchUserBookings(String userId) {
    return firestore
        .collection(FirebaseConstants.bookingsCollection)
        .where('homeownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<List<BookingModel>> watchTechnicianBookings(String technicianId) {
    return firestore
        .collection(FirebaseConstants.bookingsCollection)
        .where('technicianId', isEqualTo: technicianId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<BookingModel?> watchBooking(String bookingId) {
    return firestore
        .collection(FirebaseConstants.bookingsCollection)
        .doc(bookingId)
        .snapshots()
        .map((doc) => doc.exists ? BookingModel.fromFirestore(doc) : null);
  }

  @override
  Future<void> createBooking(BookingModel booking) async {
    await firestore
        .collection(FirebaseConstants.bookingsCollection)
        .doc(booking.id)
        .set(booking.toFirestore());
  }

  @override
  Future<void> updateStatus(String bookingId, String status) async {
    await firestore
        .collection(FirebaseConstants.bookingsCollection)
        .doc(bookingId)
        .update({'status': status});
  }
}