// lib/domain/usecases/booking/booking_usecase.dart
import '../../entities/booking.dart';
import '../../repositories/booking_repository.dart';

class BookingUseCase {
  final BookingRepository repository;

  BookingUseCase(this.repository);

  // Create a new booking
  Future<BookingEntity> createBooking({
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
    // Validate inputs
    if (homeownerId.isEmpty) throw Exception('Homeowner ID is required');
    if (technicianId.isEmpty) throw Exception('Technician ID is required');
    if (serviceId.isEmpty) throw Exception('Service ID is required');
    if (scheduledTime.isBefore(DateTime.now())) {
      throw Exception('Scheduled time must be in the future');
    }
    if (address.isEmpty) throw Exception('Address is required');
    if (totalPrice <= 0) throw Exception('Total price must be greater than 0');

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

  // Get bookings for a user (homeowner)
  Future<List<BookingEntity>> getUserBookings(String userId) async {
    if (userId.isEmpty) throw Exception('User ID is required');
    return await repository.getUserBookings(userId);
  }

  // Get bookings for a technician
  Future<List<BookingEntity>> getTechnicianBookings(String technicianId) async {
    if (technicianId.isEmpty) throw Exception('Technician ID is required');
    return await repository.getTechnicianBookings(technicianId);
  }

  // Get single booking by ID
  Future<BookingEntity?> getBookingById(String bookingId) async {
    if (bookingId.isEmpty) throw Exception('Booking ID is required');
    return await repository.getBookingById(bookingId);
  }

  // Update booking status
  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    if (bookingId.isEmpty) throw Exception('Booking ID is required');
    
    final booking = await repository.getBookingById(bookingId);
    if (booking == null) throw Exception('Booking not found');
    
    await repository.updateBookingStatus(bookingId, status);
  }

  // Cancel a booking (homeowner)
  Future<void> cancelBooking(String bookingId) async {
    if (bookingId.isEmpty) throw Exception('Booking ID is required');
    
    final booking = await repository.getBookingById(bookingId);
    if (booking == null) throw Exception('Booking not found');
    
    if (booking.status == BookingStatus.completed) {
      throw Exception('Cannot cancel a completed booking');
    }
    
    if (booking.status == BookingStatus.cancelled) {
      throw Exception('Booking is already cancelled');
    }
    
    await repository.updateBookingStatus(bookingId, BookingStatus.cancelled);
  }

  // Accept booking (technician)
  Future<void> acceptBooking(String bookingId) async {
    if (bookingId.isEmpty) throw Exception('Booking ID is required');
    
    final booking = await repository.getBookingById(bookingId);
    if (booking == null) throw Exception('Booking not found');
    
    if (booking.status != BookingStatus.pending) {
      throw Exception('Can only accept pending bookings');
    }
    
    await repository.updateBookingStatus(bookingId, BookingStatus.accepted);
  }

  // Decline booking (technician)
  Future<void> declineBooking(String bookingId) async {
    if (bookingId.isEmpty) throw Exception('Booking ID is required');
    
    final booking = await repository.getBookingById(bookingId);
    if (booking == null) throw Exception('Booking not found');
    
    if (booking.status != BookingStatus.pending) {
      throw Exception('Can only decline pending bookings');
    }
    
    await repository.updateBookingStatus(bookingId, BookingStatus.cancelled);
  }

  // Start booking work (technician)
  Future<void> startBooking(String bookingId) async {
    if (bookingId.isEmpty) throw Exception('Booking ID is required');
    
    final booking = await repository.getBookingById(bookingId);
    if (booking == null) throw Exception('Booking not found');
    
    if (booking.status != BookingStatus.accepted) {
      throw Exception('Can only start accepted bookings');
    }
    
    await repository.updateBookingStatus(bookingId, BookingStatus.inProgress);
  }

  // Complete booking
  Future<void> completeBooking(String bookingId) async {
    if (bookingId.isEmpty) throw Exception('Booking ID is required');
    
    final booking = await repository.getBookingById(bookingId);
    if (booking == null) throw Exception('Booking not found');
    
    if (booking.status != BookingStatus.inProgress) {
      throw Exception('Can only complete bookings that are in progress');
    }
    
    await repository.updateBookingStatus(bookingId, BookingStatus.completed);
  }

  // Get pending bookings
  Future<List<BookingEntity>> getPendingBookings(String userId, {bool isTechnician = false}) async {
    if (userId.isEmpty) throw Exception('User ID is required');
    
    final bookings = isTechnician
        ? await repository.getTechnicianBookings(userId)
        : await repository.getUserBookings(userId);
    
    return bookings.where((b) => b.status == BookingStatus.pending).toList();
  }

  // Get active bookings
  Future<List<BookingEntity>> getActiveBookings(String userId, {bool isTechnician = false}) async {
    if (userId.isEmpty) throw Exception('User ID is required');
    
    final bookings = isTechnician
        ? await repository.getTechnicianBookings(userId)
        : await repository.getUserBookings(userId);
    
    return bookings.where(
      (b) => b.status == BookingStatus.accepted || b.status == BookingStatus.inProgress
    ).toList();
  }

  // Get completed bookings
  Future<List<BookingEntity>> getCompletedBookings(String userId, {bool isTechnician = false}) async {
    if (userId.isEmpty) throw Exception('User ID is required');
    
    final bookings = isTechnician
        ? await repository.getTechnicianBookings(userId)
        : await repository.getUserBookings(userId);
    
    return bookings.where((b) => b.status == BookingStatus.completed).toList();
  }

  // Get cancelled bookings
  Future<List<BookingEntity>> getCancelledBookings(String userId, {bool isTechnician = false}) async {
    if (userId.isEmpty) throw Exception('User ID is required');
    
    final bookings = isTechnician
        ? await repository.getTechnicianBookings(userId)
        : await repository.getUserBookings(userId);
    
    return bookings.where((b) => b.status == BookingStatus.cancelled).toList();
  }

  // Get bookings by date range
  Future<List<BookingEntity>> getBookingsByDateRange(
    String userId, {
    required DateTime startDate,
    required DateTime endDate,
    bool isTechnician = false,
  }) async {
    if (userId.isEmpty) throw Exception('User ID is required');
    if (startDate.isAfter(endDate)) throw Exception('Start date must be before end date');
    
    final bookings = isTechnician
        ? await repository.getTechnicianBookings(userId)
        : await repository.getUserBookings(userId);
    
    return bookings.where((b) =>
      b.scheduledTime.isAfter(startDate) && b.scheduledTime.isBefore(endDate)
    ).toList();
  }

  // Get today's bookings
  Future<List<BookingEntity>> getTodayBookings(String userId, {bool isTechnician = false}) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    return await getBookingsByDateRange(
      userId,
      startDate: todayStart,
      endDate: todayEnd,
      isTechnician: isTechnician,
    );
  }

  // Check if booking slot is available
  Future<bool> isTimeSlotAvailable(
    String technicianId,
    DateTime scheduledTime,
  ) async {
    final bookings = await repository.getTechnicianBookings(technicianId);
    
    // Check if any existing booking overlaps with the requested time
    final hasConflict = bookings.any((booking) {
      if (booking.status == BookingStatus.cancelled) return false;
      
      final bookingStart = booking.scheduledTime;
      final bookingEnd = bookingStart.add(const Duration(hours: 2)); // Assume 2-hour slots
      
      return scheduledTime.isBefore(bookingEnd) && 
             scheduledTime.add(const Duration(hours: 2)).isAfter(bookingStart);
    });
    
    return !hasConflict;
  }

  // Get booking statistics
  Future<Map<String, dynamic>> getBookingStats(String userId, {bool isTechnician = false}) async {
    final bookings = isTechnician
        ? await repository.getTechnicianBookings(userId)
        : await repository.getUserBookings(userId);
    
    return {
      'total': bookings.length,
      'pending': bookings.where((b) => b.status == BookingStatus.pending).length,
      'accepted': bookings.where((b) => b.status == BookingStatus.accepted).length,
      'inProgress': bookings.where((b) => b.status == BookingStatus.inProgress).length,
      'completed': bookings.where((b) => b.status == BookingStatus.completed).length,
      'cancelled': bookings.where((b) => b.status == BookingStatus.cancelled).length,
      'totalEarnings': bookings
          .where((b) => b.status == BookingStatus.completed)
          .fold(0.0, (sum, b) => sum + b.totalPrice),
    };
  }
}