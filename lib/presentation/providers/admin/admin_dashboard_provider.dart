// lib/presentation/providers/admin/admin_dashboard_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/firebase_service.dart';

part 'admin_dashboard_provider.g.dart';

class DashboardState {
  final int totalUsers;
  final int totalTechnicians;
  final int totalBookings;
  final double totalRevenue;
  final int pendingVerifications;
  final int activeJobs;
  final double completionRate;
  final String selectedPeriod;
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.totalUsers = 0,
    this.totalTechnicians = 0,
    this.totalBookings = 0,
    this.totalRevenue = 0.0,
    this.pendingVerifications = 0,
    this.activeJobs = 0,
    this.completionRate = 0.0,
    this.selectedPeriod = 'Today',
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    int? totalUsers,
    int? totalTechnicians,
    int? totalBookings,
    double? totalRevenue,
    int? pendingVerifications,
    int? activeJobs,
    double? completionRate,
    String? selectedPeriod,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      totalUsers: totalUsers ?? this.totalUsers,
      totalTechnicians: totalTechnicians ?? this.totalTechnicians,
      totalBookings: totalBookings ?? this.totalBookings,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      pendingVerifications: pendingVerifications ?? this.pendingVerifications,
      activeJobs: activeJobs ?? this.activeJobs,
      completionRate: completionRate ?? this.completionRate,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

@riverpod
class DashboardNotifier extends _$DashboardNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  DashboardState build() {
    loadData();
    return const DashboardState();
  }

  void setPeriod(String period) {
    state = state.copyWith(selectedPeriod: period);
    loadData();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await Future.wait([
        _firebaseService.usersRef.count().get(),
        _firebaseService.techniciansRef.count().get(),
        _firebaseService.bookingsRef.count().get(),
        _firebaseService.techniciansRef.where('verificationStatus', isEqualTo: 'pending').count().get(),
        _firebaseService.bookingsRef.where('status', isEqualTo: 'inProgress').count().get(),
        _firebaseService.bookingsRef.get(),
      ]);

      final totalUsers = (results[0] as AggregateQuerySnapshot).count;
      final totalTechnicians = (results[1] as AggregateQuerySnapshot).count;
      final totalBookings = (results[2] as AggregateQuerySnapshot).count;
      final pendingVerifications = (results[3] as AggregateQuerySnapshot).count;
      final activeJobs = (results[4] as AggregateQuerySnapshot).count;
      final bookingsSnapshot = results[5] as QuerySnapshot;
      
      double totalRevenue = 0;
      int completedBookings = 0;

      for (final doc in bookingsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        if (data['status'] == 'completed') {
          completedBookings++;
          totalRevenue += (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
        }
      }

      final total = totalBookings?? 0;
      final completionRate = total > 0 ? (completedBookings / total) * 100 : 0.0;

      state = state.copyWith(
        totalUsers: totalUsers,
        totalTechnicians: totalTechnicians,
        totalBookings: totalBookings,
        totalRevenue: totalRevenue,
        pendingVerifications: pendingVerifications,
        activeJobs: activeJobs,
        completionRate: completionRate,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}