// lib/presentation/providers/technician/technician_guard_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/firebase_service.dart';

part 'technician_guard_provider.g.dart';

@riverpod
class TechnicianGuard extends _$TechnicianGuard {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Future<bool> build() async => false;

  Future<bool> isProfileComplete(String technicianId) async {
    state = const AsyncValue.loading();
    try {
      final doc = await _firebaseService.techniciansRef.doc(technicianId).get();
      if (!doc.exists) {
        state = const AsyncValue.data(false);
        return false;
      }
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final isComplete = data['verificationStatus'] == 'verified' || 
                         data['verificationStatus'] == 'pending';
      state = AsyncValue.data(isComplete);
      return isComplete;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }
}