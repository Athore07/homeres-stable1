// lib/presentation/providers/homeowner/booking_history_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/firebase_service.dart';
import '../../../domain/entities/booking.dart';

part 'booking_history_provider.g.dart';

class BookingHistoryState {
  final List<Map<String, dynamic>> bookings;
  final String selectedFilter;
  final bool isLoading;
  final String? error;

  const BookingHistoryState({this.bookings = const [], this.selectedFilter = 'All', this.isLoading = true, this.error});

  List<Map<String, dynamic>> get filtered {
    if (selectedFilter == 'All') return bookings;
    return bookings.where((b) {
      final s = b['status'] as BookingStatus;
      return switch (selectedFilter) {
        'Pending' => s == BookingStatus.pending,
        'In Progress' => s == BookingStatus.inProgress,
        'Completed' => s == BookingStatus.completed,
        'Cancelled' => s == BookingStatus.cancelled,
        _ => true,
      };
    }).toList();
  }

  BookingHistoryState copyWith({List<Map<String, dynamic>>? bookings, String? selectedFilter, bool? isLoading, String? error}) {
    return BookingHistoryState(bookings: bookings ?? this.bookings, selectedFilter: selectedFilter ?? this.selectedFilter, isLoading: isLoading ?? this.isLoading, error: error);
  }
}

@riverpod
class BookingHistoryNotifier extends _$BookingHistoryNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  BookingHistoryState build() => const BookingHistoryState(isLoading: false);

  void setFilter(String f) => state = state.copyWith(selectedFilter: f);

  Future<void> loadBookings(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final snapshot = await _firebaseService.bookingsRef.where('homeownerId', isEqualTo: userId).orderBy('createdAt', descending: true).get();

      final bookings = <Map<String, dynamic>>[];
      for (final doc in snapshot.docs) {
        final d = doc.data() as Map<String, dynamic>? ?? {};
        final techId = d['technicianId'] as String? ?? '';
        String techName = 'Unknown';
        double rating = 0;

        if (techId.isNotEmpty) {
          try {
            final tDoc = await _firebaseService.techniciansRef.doc(techId).get();
            if (tDoc.exists) {
              final td = tDoc.data() as Map<String, dynamic>? ?? {};
              techName = td['name'] as String? ?? 'Unknown';
              rating = (td['rating'] as num?)?.toDouble() ?? 0.0;
            }
          } catch (_) {}
        }

        bookings.add({
          'id': doc.id,
          'service': d['serviceName'] ?? 'Unknown',
          'technician': techName,
          'date': (d['scheduledTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
          'status': _parseStatus(d['status']),
          'price': (d['totalPrice'] as num?)?.toDouble() ?? 0.0,
          'rating': rating,
          'address': d['address'] ?? '',
          'description': d['description'] ?? '',
        });
      }

      state = state.copyWith(bookings: bookings, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  BookingStatus _parseStatus(String? s) => BookingStatus.values.firstWhere((e) => e.name == (s ?? 'pending'), orElse: () => BookingStatus.pending);
}