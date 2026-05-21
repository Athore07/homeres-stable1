// lib/presentation/providers/admin/analytics_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/firebase_service.dart';

part 'analytics_provider.g.dart';

class AnalyticsState {
  final double totalRevenue;
  final int totalBookings;
  final int totalUsers;
  final double completionRate;
  final double revenueGrowth;
  final Map<String, int> monthlyBookings;
  final List<Map<String, dynamic>> topServices;
  final List<Map<String, dynamic>> topTechnicians;
  final String selectedPeriod;
  final bool isLoading;
  final String? error;

  const AnalyticsState({
    this.totalRevenue = 0.0,
    this.totalBookings = 0,
    this.totalUsers = 0,
    this.completionRate = 0.0,
    this.revenueGrowth = 0.0,
    this.monthlyBookings = const {},
    this.topServices = const [],
    this.topTechnicians = const [],
    this.selectedPeriod = 'This Month',
    this.isLoading = false,
    this.error,
  });

  AnalyticsState copyWith({
    double? totalRevenue,
    int? totalBookings,
    int? totalUsers,
    double? completionRate,
    double? revenueGrowth,
    Map<String, int>? monthlyBookings,
    List<Map<String, dynamic>>? topServices,
    List<Map<String, dynamic>>? topTechnicians,
    String? selectedPeriod,
    bool? isLoading,
    String? error,
  }) {
    return AnalyticsState(
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalBookings: totalBookings ?? this.totalBookings,
      totalUsers: totalUsers ?? this.totalUsers,
      completionRate: completionRate ?? this.completionRate,
      revenueGrowth: revenueGrowth ?? this.revenueGrowth,
      monthlyBookings: monthlyBookings ?? this.monthlyBookings,
      topServices: topServices ?? this.topServices,
      topTechnicians: topTechnicians ?? this.topTechnicians,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

@riverpod
class AnalyticsNotifier extends _$AnalyticsNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  AnalyticsState build() {
    loadData();
    return const AnalyticsState();
  }

  void setPeriod(String period) {
    state = state.copyWith(selectedPeriod: period);
    loadData();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await Future.wait([
        _firebaseService.bookingsRef.get(),
        _firebaseService.usersRef.get(),
        _firebaseService.techniciansRef.get(),
      ]);

      final bookingsSnapshot = results[0];
      final usersSnapshot = results[1];
      final techniciansSnapshot = results[2];

      double totalRevenue = 0;
      int completedBookings = 0;
      int cancelledBookings = 0;
      final Map<String, int> monthlyBookings = {};
      final Map<String, int> serviceBookings = {};
      final Map<String, double> technicianRevenue = {};
      final Map<String, int> technicianJobs = {};
      final Map<String, String> technicianNames = {};
      final Map<String, double> technicianRatings = {};

      for (final doc in bookingsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        final status = data['status'] as String? ?? '';
        final price = (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
        final date = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        final serviceName = data['serviceName'] as String? ?? 'Unknown';
        final technicianId = data['technicianId'] as String? ?? '';
        final monthKey = DateFormat('MMM').format(date);

        monthlyBookings[monthKey] = (monthlyBookings[monthKey] ?? 0) + 1;
        serviceBookings[serviceName] = (serviceBookings[serviceName] ?? 0) + 1;

        if (technicianId.isNotEmpty) {
          technicianRevenue[technicianId] = (technicianRevenue[technicianId] ?? 0) + price;
          technicianJobs[technicianId] = (technicianJobs[technicianId] ?? 0) + 1;
        }

        if (status == 'completed') {
          totalRevenue += price;
          completedBookings++;
        } else if (status == 'cancelled') {
          cancelledBookings++;
        }
      }

      for (final doc in techniciansSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        technicianNames[doc.id] = data['name'] as String? ?? 'Unknown';
        technicianRatings[doc.id] = (data['rating'] as num?)?.toDouble() ?? 0.0;
      }

      final totalBookings = bookingsSnapshot.docs.length;
      final completionRate = totalBookings > 0 ? (completedBookings / (totalBookings - cancelledBookings) * 100) : 0.0;

      final now = DateTime.now();
      final thisMonthRevenue = _getMonthRevenue(bookingsSnapshot, now.month, now.year);
      final lastMonthRevenue = _getMonthRevenue(bookingsSnapshot, now.month - 1, now.year);
      final revenueGrowth = lastMonthRevenue > 0 ? ((thisMonthRevenue - lastMonthRevenue) / lastMonthRevenue * 100) : 0.0;

      final topServices = serviceBookings.entries
          .map((e) => {'name': e.key, 'bookings': e.value, 'percentage': totalBookings > 0 ? e.value / totalBookings : 0.0})
          .toList()
        ..sort((a, b) => (b['bookings'] as int).compareTo(a['bookings'] as int));

      final topTechnicians = technicianRevenue.entries
          .map((e) => {'name': technicianNames[e.key] ?? 'Unknown', 'technicianId': e.key, 'revenue': e.value, 'jobs': technicianJobs[e.key] ?? 0, 'rating': technicianRatings[e.key] ?? 0.0})
          .toList()
        ..sort((a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double));

      state = state.copyWith(
        totalRevenue: totalRevenue,
        totalBookings: totalBookings,
        totalUsers: usersSnapshot.docs.length,
        completionRate: completionRate,
        revenueGrowth: revenueGrowth,
        monthlyBookings: monthlyBookings,
        topServices: topServices.take(5).toList(),
        topTechnicians: topTechnicians.take(5).toList(),
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  double _getMonthRevenue(QuerySnapshot bookingsSnapshot, int month, int year) {
    double revenue = 0;
    for (final doc in bookingsSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final date = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
      if (date.month == month && date.year == year && data['status'] == 'completed') {
        revenue += (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
      }
    }
    return revenue;
  }
}