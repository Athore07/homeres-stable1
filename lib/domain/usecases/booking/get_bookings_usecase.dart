// lib/domain/usecases/booking/get_bookings_usecase.dart
import '../../entities/booking.dart';
import '../../repositories/booking_repository.dart';

class GetBookingsUseCase {
  final BookingRepository repository;

  GetBookingsUseCase(this.repository);

  Future<List<BookingEntity>> call(String userId) async {
    return await repository.getUserBookings(userId);
  }
}