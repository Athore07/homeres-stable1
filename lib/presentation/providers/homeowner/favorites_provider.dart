// lib/presentation/providers/homeowner/favorites_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/utils/location_utils.dart';

part 'favorites_provider.g.dart';

class FavoritesState {
  final List<Map<String, dynamic>> favorites;
  final bool isLoading;
  final String? error;

  const FavoritesState({this.favorites = const [], this.isLoading = false, this.error});

  FavoritesState copyWith({List<Map<String, dynamic>>? favorites, bool? isLoading, String? error}) {
    return FavoritesState(favorites: favorites ?? this.favorites, isLoading: isLoading ?? this.isLoading, error: error);
  }
}

@riverpod
class FavoritesNotifier extends _$FavoritesNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  FavoritesState build() => const FavoritesState();

  Future<void> loadFavorites(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Get user's favorite technician IDs
      final userDoc = await _firebaseService.usersRef.doc(userId).get();
      final userData = userDoc.data() as Map<String, dynamic>? ?? {};
      final favoriteIds = List<String>.from(userData['favorites'] ?? []);

      if (favoriteIds.isEmpty) {
        state = state.copyWith(favorites: [], isLoading: false);
        return;
      }

      // Fetch favorite technicians
      final favorites = <Map<String, dynamic>>[];
      for (final id in favoriteIds) {
        try {
          final doc = await _firebaseService.techniciansRef.doc(id).get();
          if (doc.exists) {
            final d = doc.data() as Map<String, dynamic>? ?? {};
            final loc = d['location'] as GeoPoint?;
            favorites.add({
              'id': doc.id,
              'name': d['name'] as String? ?? 'Unknown',
              'specialty': d['specialty'] as String? ?? 'General',
              'rating': (d['rating'] as num?)?.toDouble() ?? 0.0,
              'totalJobs': (d['totalJobs'] as num?)?.toInt() ?? 0,
              'isAvailable': d['isAvailable'] == true,
              'hourlyRate': (d['hourlyRate'] as num?)?.toDouble() ?? 0.0,
              'latitude': loc?.latitude ?? 0.0,
              'longitude': loc?.longitude ?? 0.0,
              'distance': loc != null ? LocationUtils.calculateDistance(-6.369028, 34.888822, loc.latitude, loc.longitude) : 0.0,
            });
          }
        } catch (_) {}
      }

      state = state.copyWith(favorites: favorites, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> removeFavorite(String userId, String technicianId) async {
    try {
      await _firebaseService.usersRef.doc(userId).update({
        'favorites': FieldValue.arrayRemove([technicianId]),
      });
      state = state.copyWith(favorites: state.favorites.where((f) => f['id'] != technicianId).toList());
    } catch (e) {
      state = state.copyWith(error: 'Failed to remove favorite');
    }
  }

  Future<void> addFavorite(String userId, String technicianId) async {
    try {
      await _firebaseService.usersRef.doc(userId).update({
        'favorites': FieldValue.arrayUnion([technicianId]),
      });
      await loadFavorites(userId);
    } catch (e) {
      state = state.copyWith(error: 'Failed to add favorite');
    }
  }
}