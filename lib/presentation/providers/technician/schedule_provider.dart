// lib/presentation/providers/technician/schedule_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../../core/services/firebase_service.dart';
import '../../../domain/entities/booking.dart';

part 'schedule_provider.g.dart';

class ScheduleState {
  final Map<String, List<Map<String, dynamic>>> scheduleData;
  final DateTime selectedDate;
  final bool isLoading;
  final String? error;

  const ScheduleState({
    this.scheduleData = const {},
    required this.selectedDate,
    this.isLoading = false,
    this.error,
  });

  String get dateKey => DateFormat('yyyy-MM-dd').format(selectedDate);
  List<Map<String, dynamic>> get todayJobs => scheduleData[dateKey] ?? [];
  bool hasJobs(String key) => (scheduleData[key]?.length ?? 0) > 0;

  ScheduleState copyWith({
    Map<String, List<Map<String, dynamic>>>? scheduleData, DateTime? selectedDate, bool? isLoading, String? error,
  }) {
    return ScheduleState(
      scheduleData: scheduleData ?? this.scheduleData, selectedDate: selectedDate ?? this.selectedDate,
      isLoading: isLoading ?? this.isLoading, error: error,
    );
  }
}

@riverpod
class ScheduleNotifier extends _$ScheduleNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription? _subscription;

  @override
  ScheduleState build() => ScheduleState(selectedDate: DateTime.now());

  void selectDate(DateTime date) => state = state.copyWith(selectedDate: date);

  // Start real-time listener
  void startListening(String technicianId) {
    _subscription?.cancel();
    state = state.copyWith(isLoading: true, error: null);

    final startDate = DateTime.now().subtract(const Duration(days: 1));
    final endDate = DateTime.now().add(const Duration(days: 14));

    _subscription = _firebaseService.bookingsRef
        .where('technicianId', isEqualTo: technicianId)
        .where('status', whereIn: ['pending', 'accepted', 'inProgress'])
        .where('scheduledTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('scheduledTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('scheduledTime')
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
    final Map<String, List<Map<String, dynamic>>> data = {};

    for (final doc in snapshot.docs) {
      final d = doc.data() as Map<String, dynamic>? ?? {};
      final scheduledTime = (d['scheduledTime'] as Timestamp?)?.toDate() ?? DateTime.now();
      final key = DateFormat('yyyy-MM-dd').format(scheduledTime);
      final time = DateFormat('hh:mm a').format(scheduledTime);

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

      data.putIfAbsent(key, () => []).add({
        'id': doc.id,
        'customer': customerName,
        'service': d['serviceName'] ?? 'Unknown',
        'time': time,
        'address': d['address'] ?? '',
        'status': _parseStatus(d['status']),
        'scheduledTime': scheduledTime,
        'description': d['description'] ?? '',
      });
    }

    state = state.copyWith(scheduleData: data, isLoading: false);
  }

  BookingStatus _parseStatus(String? s) => BookingStatus.values.firstWhere(
    (e) => e.name == (s ?? 'pending'),
    orElse: () => BookingStatus.pending,
  );

  void dispose() {
    _subscription?.cancel();
  }
}