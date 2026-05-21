// lib/presentation/providers/booking/booking_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/booking.dart';
import '../../../domain/usecases/booking/booking_usecase.dart';
import 'booking_providers.dart';

part 'booking_provider.g.dart';

// Booking State
class BookingState {
  final List<BookingEntity> bookings;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? stats;

  const BookingState({
    this.bookings = const [],
    this.isLoading = false,
    this.error,
    this.stats,
  });

  BookingState copyWith({
    List<BookingEntity>? bookings,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? stats,
  }) {
    return BookingState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      stats: stats ?? this.stats,
    );
  }

  factory BookingState.initial() => const BookingState();
}

@riverpod
class BookingNotifier extends _$BookingNotifier {
  BookingUseCase get _bookingUseCase => ref.read(bookingUseCaseProvider);

  @override
  BookingState build() {
    return BookingState.initial();
  }

  Future<void> loadUserBookings(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final bookings = await _bookingUseCase.getUserBookings(userId);
      final stats = await _bookingUseCase.getBookingStats(userId);
      state = state.copyWith(bookings: bookings, stats: stats, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loadTechnicianBookings(String technicianId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final bookings = await _bookingUseCase.getTechnicianBookings(technicianId);
      final stats = await _bookingUseCase.getBookingStats(technicianId, isTechnician: true);
      state = state.copyWith(bookings: bookings, stats: stats, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<BookingEntity?> createBooking({
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
    state = state.copyWith(isLoading: true, error: null);
    try {
      final booking = await _bookingUseCase.createBooking(
        homeownerId: homeownerId,
        technicianId: technicianId,
        serviceId: serviceId,
        serviceName: serviceName,
        scheduledTime: scheduledTime,
        address: address,
        latitude: latitude,
        longitude: longitude,
        description: description,
        totalPrice: totalPrice,
      );
      
      state = state.copyWith(
        bookings: [booking, ...state.bookings],
        isLoading: false,
      );
      
      return booking;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return null;
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _bookingUseCase.cancelBooking(bookingId);
      final updatedBookings = state.bookings.map((b) {
        if (b.id == bookingId) {
          return BookingEntity(
            id: b.id,
            homeownerId: b.homeownerId,
            technicianId: b.technicianId,
            serviceId: b.serviceId,
            serviceName: b.serviceName,
            scheduledTime: b.scheduledTime,
            status: BookingStatus.cancelled,
            address: b.address,
            latitude: b.latitude,
            longitude: b.longitude,
            description: b.description,
            totalPrice: b.totalPrice,
            createdAt: b.createdAt,
          );
        }
        return b;
      }).toList();
      
      state = state.copyWith(bookings: updatedBookings);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> acceptBooking(String bookingId) async {
    try {
      await _bookingUseCase.acceptBooking(bookingId);
      await _updateBookingStatusLocally(bookingId, BookingStatus.accepted);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> declineBooking(String bookingId) async {
    try {
      await _bookingUseCase.declineBooking(bookingId);
      await _updateBookingStatusLocally(bookingId, BookingStatus.cancelled);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> startBooking(String bookingId) async {
    try {
      await _bookingUseCase.startBooking(bookingId);
      await _updateBookingStatusLocally(bookingId, BookingStatus.inProgress);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> completeBooking(String bookingId) async {
    try {
      await _bookingUseCase.completeBooking(bookingId);
      await _updateBookingStatusLocally(bookingId, BookingStatus.completed);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadPendingBookings(String userId, {bool isTechnician = false}) async {
    state = state.copyWith(isLoading: true);
    try {
      final bookings = await _bookingUseCase.getPendingBookings(userId, isTechnician: isTechnician);
      state = state.copyWith(bookings: bookings, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loadActiveBookings(String userId, {bool isTechnician = false}) async {
    state = state.copyWith(isLoading: true);
    try {
      final bookings = await _bookingUseCase.getActiveBookings(userId, isTechnician: isTechnician);
      state = state.copyWith(bookings: bookings, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loadCompletedBookings(String userId, {bool isTechnician = false}) async {
    state = state.copyWith(isLoading: true);
    try {
      final bookings = await _bookingUseCase.getCompletedBookings(userId, isTechnician: isTechnician);
      state = state.copyWith(bookings: bookings, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<bool> checkTimeSlotAvailability(String technicianId, DateTime scheduledTime) async {
    try {
      return await _bookingUseCase.isTimeSlotAvailable(technicianId, scheduledTime);
    } catch (e) {
      return false;
    }
  }

  Future<void> _updateBookingStatusLocally(String bookingId, BookingStatus status) async {
    final updatedBookings = state.bookings.map((b) {
      if (b.id == bookingId) {
        return BookingEntity(
          id: b.id,
          homeownerId: b.homeownerId,
          technicianId: b.technicianId,
          serviceId: b.serviceId,
          serviceName: b.serviceName,
          scheduledTime: b.scheduledTime,
          status: status,
          address: b.address,
          latitude: b.latitude,
          longitude: b.longitude,
          description: b.description,
          totalPrice: b.totalPrice,
          createdAt: b.createdAt,
          completedAt: status == BookingStatus.completed ? DateTime.now() : b.completedAt,
        );
      }
      return b;
    }).toList();
    
    state = state.copyWith(bookings: updatedBookings);
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}

// Derived providers
@riverpod
List<BookingEntity> pendingBookings(Ref ref) {
  final bookingState = ref.watch(bookingProvider);
  return bookingState.bookings.where((b) => b.status == BookingStatus.pending).toList();
}

@riverpod
List<BookingEntity> activeBookings(Ref ref) {
  final bookingState = ref.watch(bookingProvider);
  return bookingState.bookings
      .where((b) => b.status == BookingStatus.accepted || b.status == BookingStatus.inProgress)
      .toList();
}

@riverpod
List<BookingEntity> completedBookings(Ref ref) {
  final bookingState = ref.watch(bookingProvider);
  return bookingState.bookings.where((b) => b.status == BookingStatus.completed).toList();
}

@riverpod
int pendingBookingsCount(Ref ref) {
  return ref.watch(pendingBookingsProvider).length;
}

@riverpod
int activeBookingsCount(Ref ref) {
  return ref.watch(activeBookingsProvider).length;
}