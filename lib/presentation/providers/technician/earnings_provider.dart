// lib/presentation/providers/technician/earnings_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:async';
import '../../../core/services/firebase_service.dart';

part 'earnings_provider.g.dart';

class EarningsState {
  final List<Map<String, dynamic>> transactions;
  final double totalEarnings;
  final String selectedPeriod;
  final bool isLoading;
  final String? error;

  const EarningsState({
    this.transactions = const [],
    this.totalEarnings = 0.0,
    this.selectedPeriod = 'This Week',
    this.isLoading = false,
    this.error,
  });

  List<Map<String, dynamic>> get filteredTransactions {
    final now = DateTime.now();
    return transactions.where((t) {
      final date = t['date'] as DateTime;
      return switch (selectedPeriod) {
        'This Week' => date.isAfter(now.subtract(const Duration(days: 7))),
        'This Month' => date.isAfter(DateTime(now.year, now.month, 1)),
        'This Year' => date.isAfter(DateTime(now.year, 1, 1)),
        _ => true,
      };
    }).toList();
  }

  double get filteredTotal => filteredTransactions.fold(0.0, (sum, t) => sum + (t['amount'] as double));

  EarningsState copyWith({
    List<Map<String, dynamic>>? transactions, double? totalEarnings, String? selectedPeriod, bool? isLoading, String? error,
  }) {
    return EarningsState(
      transactions: transactions ?? this.transactions, totalEarnings: totalEarnings ?? this.totalEarnings,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod, isLoading: isLoading ?? this.isLoading, error: error,
    );
  }
}

@riverpod
class EarningsNotifier extends _$EarningsNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription? _subscription;

  @override
  EarningsState build() => const EarningsState();

  void setPeriod(String period) => state = state.copyWith(selectedPeriod: period);

  // Start listening for real-time changes
  void startListening(String technicianId) {
    _subscription?.cancel();
    state = state.copyWith(isLoading: true, error: null);

    _subscription = _firebaseService.bookingsRef
        .where('technicianId', isEqualTo: technicianId)
        .where('status', isEqualTo: 'completed')
        .orderBy('completedAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) => _processSnapshot(snapshot),
          onError: (e) => state = state.copyWith(isLoading: false, error: e.toString()),
        );
  }

  // Stop listening when no longer needed
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _processSnapshot(QuerySnapshot snapshot) async {
    final transactions = <Map<String, dynamic>>[];
    double total = 0;

    for (final doc in snapshot.docs) {
      final d = doc.data() as Map<String, dynamic>? ?? {};
      final amount = (d['totalPrice'] as num?)?.toDouble() ?? 0.0;
      total += amount;

      // Fetch customer name
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

      transactions.add({
        'id': doc.id,
        'amount': amount,
        'service': d['serviceName'] ?? 'Unknown',
        'customer': customerName,
        'date': (d['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        'address': d['address'] ?? '',
      });
    }

    state = state.copyWith(transactions: transactions, totalEarnings: total, isLoading: false);
  }

  void dispose() {
    _subscription?.cancel();
  }
}