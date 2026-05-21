// lib/presentation/providers/homeowner/tracking_provider.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart' as osm;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/utils/location_utils.dart';

part 'tracking_provider.g.dart';

class TrackingState {
  final bool isLoading;
  final String? error;
  final osm.GeoPoint? userLocation;
  final osm.GeoPoint? technicianLocation;
  final String technicianName;
  final String technicianSpecialty;
  final double technicianRating;
  final int technicianJobs;
  final String technicianPhone;
  final double distance;
  final String eta;
  final List<osm.GeoPoint> routePoints;
  final bool isListening;

  const TrackingState({
    this.isLoading = true,
    this.error,
    this.userLocation,
    this.technicianLocation,
    this.technicianName = 'Technician',
    this.technicianSpecialty = '',
    this.technicianRating = 0.0,
    this.technicianJobs = 0,
    this.technicianPhone = '',
    this.distance = 0.0,
    this.eta = 'Calculating...',
    this.routePoints = const [],
    this.isListening = false,
  });

  TrackingState copyWith({
    bool? isLoading,
    String? error,
    osm.GeoPoint? userLocation,
    osm.GeoPoint? technicianLocation,
    String? technicianName,
    String? technicianSpecialty,
    double? technicianRating,
    int? technicianJobs,
    String? technicianPhone,
    double? distance,
    String? eta,
    List<osm.GeoPoint>? routePoints,
    bool? isListening,
  }) {
    return TrackingState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userLocation: userLocation ?? this.userLocation,
      technicianLocation: technicianLocation ?? this.technicianLocation,
      technicianName: technicianName ?? this.technicianName,
      technicianSpecialty: technicianSpecialty ?? this.technicianSpecialty,
      technicianRating: technicianRating ?? this.technicianRating,
      technicianJobs: technicianJobs ?? this.technicianJobs,
      technicianPhone: technicianPhone ?? this.technicianPhone,
      distance: distance ?? this.distance,
      eta: eta ?? this.eta,
      routePoints: routePoints ?? this.routePoints,
      isListening: isListening ?? this.isListening,
    );
  }
}

@riverpod
class TrackingNotifier extends _$TrackingNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription<DocumentSnapshot>? _technicianSubscription;

  /// Native OSM map controller, assigned by the screen in [onMapIsReady].
  osm.MapController? _mapController;

  /// Instructs the provider that the native map is ready.  The controller is
  /// stored so private helper methods can perform native OSM operations (draw
  /// roads, move the camera, etc.) without depending on Flutter widget classes
  /// such as [Icon], [Color], or [MarkerIcon].
  void setMapController(osm.MapController controller) {
    _mapController = controller;
  }

  /// Whether the native map has been initialised and can accept commands.
  bool get _isMapReady => _mapController != null;

  @override
  TrackingState build() {
    ref.onDispose(() => stopListening());
    return const TrackingState();
  }

  /// Loads booking and technician details, then starts live tracking.
  Future<void> loadTracking(String bookingId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final bookingDoc = await _firebaseService.bookingsRef.doc(bookingId).get();
      if (!bookingDoc.exists) {
        state = state.copyWith(isLoading: false, error: 'Booking not found');
        return;
      }

      final booking = bookingDoc.data() as Map<String, dynamic>? ?? {};
      final technicianId = booking['technicianId'] as String? ?? '';
      final userLat =
          (booking['location'] as GeoPoint?)?.latitude ?? -6.369028;
      final userLon =
          (booking['location'] as GeoPoint?)?.longitude ?? 34.888822;

      // Fetch technician profile and current location from Firestore
      final techDoc = await _firebaseService.techniciansRef.doc(technicianId).get();
      final techData = techDoc.data() as Map<String, dynamic>? ?? {};
      final techLat =
          (techData['location'] as GeoPoint?)?.latitude ?? userLat + 0.002;
      final techLon =
          (techData['location'] as GeoPoint?)?.longitude ?? userLon + 0.002;

      final userLoc = osm.GeoPoint(latitude: userLat, longitude: userLon);
      final techLoc = osm.GeoPoint(latitude: techLat, longitude: techLon);
      final dist = LocationUtils.calculateDistance(
        userLat, userLon, techLat, techLon,
      );
      final eta = LocationUtils.getEstimatedTime(dist);

      state = state.copyWith(
        isLoading: false,
        userLocation: userLoc,
        technicianLocation: techLoc,
        technicianName: techData['name'] as String? ?? 'Technician',
        technicianSpecialty: techData['specialty'] as String? ?? '',
        technicianRating: (techData['rating'] as num?)?.toDouble() ?? 0.0,
        technicianJobs: (techData['totalJobs'] as num?)?.toInt() ?? 0,
        technicianPhone: techData['phone'] as String? ?? '',
        distance: dist,
        eta: eta,
        // Initial straight-line route is replaced with the real road polyline
        // once the native map controller is available.
        routePoints: <osm.GeoPoint>[userLoc, techLoc],
      );

      _startRealTimeTracking(technicianId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Subscribes to real-time technician location updates from Firestore.
  /// Only state is mutated here; the screen handles all native map operations
  /// in [onMapIsReady] and its post-frame listener.
  void _startRealTimeTracking(String technicianId) {
    if (technicianId.isEmpty) return;

    _technicianSubscription?.cancel();
    state = state.copyWith(isListening: true);

    _technicianSubscription = _firebaseService.techniciansRef
        .doc(technicianId)
        .snapshots()
        .listen((snapshot) async {
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final techLocation = data['location'] as GeoPoint?;

      if (techLocation != null && state.userLocation != null) {
        final newDistance = LocationUtils.calculateDistance(
          state.userLocation!.latitude,
          state.userLocation!.longitude,
          techLocation.latitude,
          techLocation.longitude,
        );
        final newEta = LocationUtils.getEstimatedTime(newDistance);

        state = state.copyWith(
          technicianLocation: osm.GeoPoint(
            latitude: techLocation.latitude,
            longitude: techLocation.longitude,
          ),
          distance: newDistance,
          eta: newEta,
          routePoints: <osm.GeoPoint>[
            state.userLocation!,
            osm.GeoPoint(
              latitude: techLocation.latitude,
              longitude: techLocation.longitude,
            ),
          ],
        );
      }
    }, onError: (error) {
      debugPrint('Tracking error: $error');
      state = state.copyWith(
        error: 'Lost connection to technician tracking',
        isListening: false,
      );
    });
  }

  /// Zooms the map camera to include both the user and the technician.
  Future<void> zoomToFit() async {
    if (!_isMapReady ||
        state.userLocation == null ||
        state.technicianLocation == null) {
      return;
    }

    final boundingBox = osm.BoundingBox.fromGeoPoints(
      <osm.GeoPoint>[state.userLocation!, state.technicianLocation!],
    );
    await _mapController!.zoomToBoundingBox(
      boundingBox,
      paddinInPixel: 50,
    );
  }

  /// Centers the map camera on the user's current location.
  Future<void> centerOnUser() async {
    if (!_isMapReady || state.userLocation == null) return;

    await _mapController!.moveTo(state.userLocation!, animate: true);
  }

  /// Centers the map camera on the technician's current location.
  Future<void> centerOnTechnician() async {
    if (!_isMapReady || state.technicianLocation == null) return;

    await _mapController!.moveTo(state.technicianLocation!, animate: true);
  }

  /// Stops the real-time Firestore location subscription.
  void stopListening() {
    _technicianSubscription?.cancel();
    _technicianSubscription = null;
    state = state.copyWith(isListening: false);
  }

  void dispose() => stopListening();
}
