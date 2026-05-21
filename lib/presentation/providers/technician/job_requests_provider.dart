// lib/presentation/providers/technician/job_requests_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:async';
import '../../../core/services/firebase_service.dart';
import '../../../domain/entities/booking.dart';

part 'job_requests_provider.g.dart';

class JobRequestsState {
  final List<Map<String, dynamic>> requests;
  final bool isLoading;
  final String? error;

  const JobRequestsState({this.requests = const [], this.isLoading = false, this.error});

  JobRequestsState copyWith({List<Map<String, dynamic>>? requests, bool? isLoading, String? error}) {
    return JobRequestsState(requests: requests ?? this.requests, isLoading: isLoading ?? this.isLoading, error: error);
  }
}

@riverpod
class JobRequestsNotifier extends _$JobRequestsNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription? _subscription;

  @override
  JobRequestsState build() => const JobRequestsState();

  // Start real-time listener
  void startListening(String technicianId) {
    _subscription?.cancel();
    state = state.copyWith(isLoading: true, error: null);

    _subscription = _firebaseService.bookingsRef
        .where('technicianId', isEqualTo: technicianId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) => _processSnapshot(snapshot),
          onError: (e) => state = state.copyWith(isLoading: false, error: e.toString()),
        );
  }

  // Stop listener
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _processSnapshot(QuerySnapshot snapshot) async {
    final requests = <Map<String, dynamic>>[];

    for (final doc in snapshot.docs) {
      final d = doc.data() as Map<String, dynamic>? ?? {};
      final homeownerId = d['homeownerId'] as String? ?? '';
      String customerName = 'Customer';

      if (homeownerId.isNotEmpty) {
        try {
          final userDoc = await _firebaseService.usersRef.doc(homeownerId).get();
          if (userDoc.exists) {
            customerName = (userDoc.data() as Map<String, dynamic>?)?['name'] ?? 'Customer';
          }
        } catch (_) {}
      }

      requests.add({
        'id': doc.id,
        'customer': customerName,
        'service': d['serviceName'] ?? 'Unknown',
        'time': _formatTime((d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now()),
        'address': d['address'] ?? '',
        'price': (d['totalPrice'] as num?)?.toDouble() ?? 0.0,
        'urgency': d['isEmergency'] == true ? 'Emergency' : 'Normal',
        'status': BookingStatus.pending,
        'description': d['description'] ?? '',
        'scheduledTime': (d['scheduledTime'] as Timestamp?)?.toDate(),
      });
    }

    state = state.copyWith(requests: requests, isLoading: false);
  }

  Future<void> acceptRequest(String bookingId) async {
    try {
      await _firebaseService.bookingsRef.doc(bookingId).update({
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });
      // Listener will automatically update the list
    } catch (e) {
      state = state.copyWith(error: 'Failed to accept request');
    }
  }

  Future<void> declineRequest(String bookingId) async {
    try {
      await _firebaseService.bookingsRef.doc(bookingId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
      // Listener will automatically update the list
    } catch (e) {
      state = state.copyWith(error: 'Failed to decline request');
    }
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

  void dispose() {
    _subscription?.cancel();
  }
}