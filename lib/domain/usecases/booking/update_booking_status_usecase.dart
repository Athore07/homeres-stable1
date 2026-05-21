// lib/domain/usecases/booking/update_booking_status_usecase.dart
import '../../entities/booking.dart';
import '../../repositories/booking_repository.dart';

class UpdateBookingStatusUseCase {
  final BookingRepository repository;

  UpdateBookingStatusUseCase(this.repository);

  Future<void> call(String bookingId, BookingStatus status) async {
    await repository.updateBookingStatus(bookingId, status);
  }
}