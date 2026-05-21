// lib/presentation/providers/homeowner/booking_detail_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/firebase_service.dart';
import '../../../domain/entities/booking.dart';

part 'booking_detail_provider.g.dart';

class BookingDetailState {
  final Map<String, dynamic>? booking;
  final Map<String, dynamic>? technician;
  final bool isLoading;
  final String? error;

  const BookingDetailState({this.booking, this.technician, this.isLoading = true, this.error});

  BookingDetailState copyWith({Map<String, dynamic>? booking, Map<String, dynamic>? technician, bool? isLoading, String? error}) {
    return BookingDetailState(booking: booking ?? this.booking, technician: technician ?? this.technician, isLoading: isLoading ?? this.isLoading, error: error);
  }
}

@riverpod
class BookingDetailNotifier extends _$BookingDetailNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  BookingDetailState build() => const BookingDetailState();

  Future<void> loadBooking(String bookingId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final doc = await _firebaseService.bookingsRef.doc(bookingId).get();
      if (!doc.exists) { state = state.copyWith(isLoading: false, error: 'Booking not found'); return; }

      final data = doc.data() as Map<String, dynamic>? ?? {};
      final techId = data['technicianId'] as String? ?? '';

      final booking = {
        'id': doc.id,
        'service': data['serviceName'] ?? 'Unknown',
        'description': data['description'] ?? '',
        'date': (data['scheduledTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
        'status': _parseStatus(data['status'] as String?),
        'address': data['address'] ?? '',
        'totalPrice': (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
        'technicianId': techId,
        'isEmergency': data['isEmergency'] == true,
      };

      Map<String, dynamic>? tech;
      if (techId.isNotEmpty) {
        final tDoc = await _firebaseService.techniciansRef.doc(techId).get();
        if (tDoc.exists) {
          final td = tDoc.data() as Map<String, dynamic>? ?? {};
          tech = {'name': td['name'] ?? 'Unknown', 'specialty': td['specialty'] ?? '', 'rating': (td['rating'] as num?)?.toDouble() ?? 0.0, 'experience': td['experience'] ?? 0, 'phone': td['phone'] ?? ''};
        }
      }

      state = state.copyWith(booking: booking, technician: tech, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  BookingStatus _parseStatus(String? s) => BookingStatus.values.firstWhere((e) => e.name == (s ?? 'pending'), orElse: () => BookingStatus.pending);

  Future<void> cancelBooking() async {
    if (state.booking == null) return;
    try {
      await _firebaseService.bookingsRef.doc(state.booking!['id'] as String).update({'status': BookingStatus.cancelled.name});
      state = state.copyWith(booking: {...state.booking!, 'status': BookingStatus.cancelled});
    } catch (e) {
      state = state.copyWith(error: 'Failed to cancel');
    }
  }
}