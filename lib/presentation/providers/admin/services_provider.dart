// lib/presentation/providers/admin/services_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/firebase_service.dart';

part 'services_provider.g.dart';

class ServicesState {
  final List<Map<String, dynamic>> services;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? editingServiceId;

  const ServicesState({
    this.services = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.editingServiceId,
  });

  ServicesState copyWith({
    List<Map<String, dynamic>>? services,
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? editingServiceId,
  }) {
    return ServicesState(
      services: services ?? this.services,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      editingServiceId: editingServiceId,
    );
  }
}

@riverpod
class ServicesNotifier extends _$ServicesNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  ServicesState build() {
    loadServices();
    return const ServicesState();
  }

  Future<void> loadServices() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final snapshot = await _firebaseService.servicesRef.orderBy('name').get();

      final services = <Map<String, dynamic>>[];
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        final techCount = await _firebaseService.techniciansRef
            .where('skills', arrayContains: data['name'] ?? '')
            .count()
            .get();
        
        services.add({
          'id': doc.id,
          'name': data['name'] ?? '',
          'category': data['category'] ?? '',
          'description': data['description'] ?? '',
          'basePrice': (data['basePrice'] as num?)?.toDouble() ?? 0.0,
          'icon': data['icon'] ?? 'build',
          'isActive': data['isActive'] ?? true,
          'createdAt': (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          'technicianCount': techCount.count,
        });
      }

      state = state.copyWith(services: services, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> saveService({
    required String name,
    required String category,
    required String description,
    required double price,
    String? serviceId,
  }) async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      final data = {
        'name': name,
        'category': category,
        'description': description,
        'basePrice': price,
        'icon': 'build',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (serviceId != null) {
        await _firebaseService.servicesRef.doc(serviceId).update(data);
      } else {
        data['isActive'] = true;
        data['createdAt'] = FieldValue.serverTimestamp();
        await _firebaseService.servicesRef.add(data);
      }

      state = state.copyWith(isSaving: false, editingServiceId: null);
      await loadServices();
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  Future<void> toggleStatus(String serviceId, bool isActive) async {
    try {
      await _firebaseService.servicesRef.doc(serviceId).update({'isActive': isActive});
      
      final updated = state.services.map((s) {
        if (s['id'] == serviceId) return {...s, 'isActive': isActive};
        return s;
      }).toList();
      
      state = state.copyWith(services: updated);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update status');
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      await _firebaseService.servicesRef.doc(serviceId).delete();
      state = state.copyWith(
        services: state.services.where((s) => s['id'] != serviceId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete service');
    }
  }

  void setEditingId(String? id) {
    state = state.copyWith(editingServiceId: id);
  }
}