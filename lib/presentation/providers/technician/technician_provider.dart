// lib/presentation/providers/technician/technician_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/firebase_service.dart';
import '../../../domain/entities/technician.dart';

part 'technician_provider.g.dart';

class TechnicianState {
  final List<TechnicianEntity> technicians;
  final List<TechnicianEntity> pendingTechnicians;
  final List<TechnicianEntity> verifiedTechnicians;
  final String selectedFilter;
  final bool isLoading;
  final String? error;
  final int pendingCount;
  final int verifiedCount;
  final int totalCount;

  const TechnicianState({
    this.technicians = const [],
    this.pendingTechnicians = const [],
    this.verifiedTechnicians = const [],
    this.selectedFilter = 'All',
    this.isLoading = false,
    this.error,
    this.pendingCount = 0,
    this.verifiedCount = 0,
    this.totalCount = 0,
  });

  TechnicianState copyWith({
    List<TechnicianEntity>? technicians,
    List<TechnicianEntity>? pendingTechnicians,
    List<TechnicianEntity>? verifiedTechnicians,
    String? selectedFilter,
    bool? isLoading,
    String? error,
    int? pendingCount,
    int? verifiedCount,
    int? totalCount,
  }) {
    return TechnicianState(
      technicians: technicians ?? this.technicians,
      pendingTechnicians: pendingTechnicians ?? this.pendingTechnicians,
      verifiedTechnicians: verifiedTechnicians ?? this.verifiedTechnicians,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      pendingCount: pendingCount ?? this.pendingCount,
      verifiedCount: verifiedCount ?? this.verifiedCount,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

@riverpod
class TechnicianNotifier extends _$TechnicianNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  TechnicianState build() {
    loadTechnicians();
    return const TechnicianState();
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
    _applyFilter(filter);
  }

  Future<void> loadTechnicians() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final snapshot = await _firebaseService.techniciansRef
          .orderBy('createdAt', descending: true)
          .get();

      final technicians = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return TechnicianEntity(
          id: doc.id,
          userId: data['userId'] as String? ?? '',
          name: data['name'] as String? ?? 'Unknown',
          email: data['email'] as String? ?? '',
          phone: data['phone'] as String? ?? '',
          specialty: data['specialty'] as String? ?? 'General',
          skills: data['skills'] != null ? List<String>.from(data['skills']) : [],
          certifications: data['certifications'] != null ? List<String>.from(data['certifications']) : [],
          experience: (data['experience'] as num?)?.toInt() ?? 0,
          hourlyRate: (data['hourlyRate'] as num?)?.toDouble() ?? 0.0,
          rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
          totalJobs: (data['totalJobs'] as num?)?.toInt() ?? 0,
          isAvailable: data['isAvailable'] == true,
          verificationStatus: data['verificationStatus'] as String? ?? 'pending',
          latitude: (data['location'] as GeoPoint?)?.latitude ?? 0.0,
          longitude: (data['location'] as GeoPoint?)?.longitude ?? 0.0,
          profileImage: data['profileImage'] as String?,
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();

      final pending = technicians.where((t) => t.verificationStatus == 'pending').toList();
      final verified = technicians.where((t) => t.verificationStatus == 'verified').toList();

      state = state.copyWith(
        technicians: technicians,
        pendingTechnicians: pending,
        verifiedTechnicians: verified,
        pendingCount: pending.length,
        verifiedCount: verified.length,
        totalCount: technicians.length,
        isLoading: false,
        error: null,
      );

      _applyFilter(state.selectedFilter);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _applyFilter(String filter) {
    List<TechnicianEntity> filtered;
    switch (filter) {
      case 'Verified':
        filtered = state.verifiedTechnicians;
        break;
      case 'Pending':
        filtered = state.pendingTechnicians;
        break;
      default:
        filtered = state.technicians;
    }
    state = state.copyWith(technicians: filtered);
  }

  Future<void> verifyTechnician(String technicianId) async {
    try {
      await _firebaseService.techniciansRef.doc(technicianId).update({
        'verificationStatus': 'verified',
        'verifiedAt': FieldValue.serverTimestamp(),
      });
      await loadTechnicians();
    } catch (e) {
      state = state.copyWith(error: 'Failed to verify technician');
    }
  }

  Future<void> rejectTechnician(String technicianId) async {
    try {
      await _firebaseService.techniciansRef.doc(technicianId).update({
        'verificationStatus': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
      });
      await loadTechnicians();
    } catch (e) {
      state = state.copyWith(error: 'Failed to reject technician');
    }
  }

  Future<void> deleteTechnician(String technicianId) async {
    try {
      await _firebaseService.techniciansRef.doc(technicianId).delete();
      await loadTechnicians();
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete technician');
    }
  }

  Future<void> toggleAvailability(String technicianId, bool isAvailable) async {
    try {
      await _firebaseService.techniciansRef.doc(technicianId).update({
        'isAvailable': isAvailable,
      });
      await loadTechnicians();
    } catch (e) {
      state = state.copyWith(error: 'Failed to update availability');
    }
  }

  Future<void> updateProfile({
    required String technicianId,
    required String name,
    required String phone,
    required String specialty,
    required double hourlyRate,
    required int experience,
    required List<String> skills,
    required List<String> certifications,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _firebaseService.techniciansRef.doc(technicianId).update({
        'name': name,
        'phone': phone,
        'specialty': specialty,
        'hourlyRate': hourlyRate,
        'experience': experience,
        'skills': skills,
        'certifications': certifications,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await loadTechnicians();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to update profile');
    }
  }

  Future<Map<String, dynamic>> getTechnicianStats(String technicianId) async {
    try {
      final bookingsSnapshot = await _firebaseService.bookingsRef
          .where('technicianId', isEqualTo: technicianId)
          .get();

      final reviewsSnapshot = await _firebaseService.reviewsRef
          .where('technicianId', isEqualTo: technicianId)
          .get();

      int totalJobs = bookingsSnapshot.docs.length;
      int completedJobs = bookingsSnapshot.docs.where((d) => d['status'] == 'completed').length;
      double totalEarnings = 0;
      int pendingJobs = bookingsSnapshot.docs.where((d) => d['status'] == 'pending').length;
      double avgRating = 0;

      for (final doc in bookingsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        if (data['status'] == 'completed') {
          totalEarnings += (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
        }
      }

      if (reviewsSnapshot.docs.isNotEmpty) {
        double totalRating = 0;
        for (final doc in reviewsSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          totalRating += (data['rating'] as num?)?.toDouble() ?? 0.0;
        }
        avgRating = totalRating / reviewsSnapshot.docs.length;
      }

      return {
        'totalJobs': totalJobs,
        'completedJobs': completedJobs,
        'totalEarnings': totalEarnings,
        'pendingJobs': pendingJobs,
        'avgRating': avgRating,
        'totalReviews': reviewsSnapshot.docs.length,
      };
    } catch (e) {
      return {};
    }
  }
}