// lib/domain/repositories/booking_repository.dart
import '../entities/booking.dart';

abstract class BookingRepository {
  Future<List<BookingEntity>> getUserBookings(String userId);
  Future<List<BookingEntity>> getTechnicianBookings(String technicianId);
  Future<BookingEntity> createBooking(BookingEntity booking);
  Future<void> updateBookingStatus(String bookingId, BookingStatus status);
  Future<BookingEntity?> getBookingById(String bookingId);
}

