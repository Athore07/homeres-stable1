// lib/domain/usecases/booking/create_booking_usecase.dart
import '../../entities/booking.dart';
import '../../repositories/booking_repository.dart';

class CreateBookingUseCase {
  final BookingRepository repository;

  CreateBookingUseCase(this.repository);

  Future<BookingEntity> call({
    required String homeownerId,
    required String technicianId,
    required String serviceId,
    required String serviceName,
    required DateTime scheduledTime,
    required String address,
    required double latitude,
    required double longitude,
    required String description,
    required double totalPrice,
  }) async {
    final booking = BookingEntity(
      id: '',
      homeownerId: homeownerId,
      technicianId: technicianId,
      serviceId: serviceId,
      serviceName: serviceName,
      scheduledTime: scheduledTime,
      status: BookingStatus.pending,
      address: address,
      latitude: latitude,
      longitude: longitude,
      description: description,
      totalPrice: totalPrice,
      createdAt: DateTime.now(),
    );
    
    return await repository.createBooking(booking);
  }
}