// lib/presentation/providers/homeowner/home_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:async';
import '../../../core/services/firebase_service.dart';
import '../../../core/utils/location_utils.dart';

part 'home_provider.g.dart';

class HomeState {
  final bool isLoading;
  final String? error;
  final double latitude;
  final double longitude;
  final String currentAddress;
  final List<Map<String, dynamic>> services;
  final List<Map<String, dynamic>> nearbyTechnicians;
  final List<Map<String, dynamic>> topTechnicians;

  const HomeState({
    this.isLoading = true,
    this.error,
    this.latitude = -6.369028,
    this.longitude = 34.888822,
    this.currentAddress = 'Loading location...',
    this.services = const [],
    this.nearbyTechnicians = const [],
    this.topTechnicians = const [],
  });

  HomeState copyWith({
    bool? isLoading,
    String? error,
    double? latitude,
    double? longitude,
    String? currentAddress,
    List<Map<String, dynamic>>? services,
    List<Map<String, dynamic>>? nearbyTechnicians,
    List<Map<String, dynamic>>? topTechnicians,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      currentAddress: currentAddress ?? this.currentAddress,
      services: services ?? this.services,
      nearbyTechnicians: nearbyTechnicians ?? this.nearbyTechnicians,
      topTechnicians: topTechnicians ?? this.topTechnicians,
    );
  }
}

@riverpod
class HomeNotifier extends _$HomeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription? _servicesSubscription;
  StreamSubscription? _techniciansSubscription;

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static String _str(dynamic v) => v?.toString() ?? '';

  @override
  HomeState build() {
    Future.microtask(_startListening);
     Future.microtask(_getLocation);
    return const HomeState();
  }

  void _startListening() {
    Future.microtask(_listenToServices);
    Future.microtask(_listenToTechnicians);
  }

  void stopListening() {
    _servicesSubscription?.cancel();
    _techniciansSubscription?.cancel();
  }

  void _listenToServices() {
    _servicesSubscription?.cancel();
    _servicesSubscription = _firebaseService.servicesRef
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen(
          (snapshot) {
            final services = snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>? ?? {};
              return {
                'id': doc.id,
                'name': _str(data['name']),
                'icon': _getServiceIcon(_str(data['name'])),
                'color': _getServiceColor(_str(data['category'])),
                'basePrice': _toDouble(data['basePrice']),
              };
            }).toList();
            state = state.copyWith(services: services, isLoading: false);
          },
          onError: (e) => state = state.copyWith(error: 'Failed to load services'),
        );
  }

  void _listenToTechnicians() {
    _techniciansSubscription?.cancel();
    _techniciansSubscription = _firebaseService.techniciansRef
        .where('isAvailable', isEqualTo: true)
        .where('verificationStatus', isEqualTo: 'verified')
        .snapshots()
        .listen(
          (snapshot) => _processTechnicians(snapshot),
          onError: (e) => state = state.copyWith(error: 'Failed to load technicians'),
        );
  }

  void _processTechnicians(QuerySnapshot snapshot) {
    final all = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final loc = data['location'] as GeoPoint?;
      double dist = 0;
      if (loc != null) {
        dist = LocationUtils.calculateDistance(
          state.latitude,
          state.longitude,
          loc.latitude,
          loc.longitude,
        );
      }
      return {
        'id': doc.id,
        'name': _str(data['name']),
        'specialty': _str(data['specialty']),
        'rating': _toDouble(data['rating']),
        'totalJobs': _toInt(data['totalJobs']),
        'distance': dist,
        'latitude': loc?.latitude ?? state.latitude,
        'longitude': loc?.longitude ?? state.longitude,
        'isAvailable': data['isAvailable'] == true,
        'hourlyRate': _toDouble(data['hourlyRate']),
      };
    }).toList();

    all.sort((a, b) => _toDouble(a['distance']).compareTo(_toDouble(b['distance'])));
    final top = List<Map<String, dynamic>>.from(all)
      ..sort((a, b) => _toDouble(b['rating']).compareTo(_toDouble(a['rating'])));

    state = state.copyWith(
      nearbyTechnicians: all.take(5).toList(),
      topTechnicians: top.take(5).toList(),
      isLoading: false,
    );
  }

  Future<void> _getLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(currentAddress: 'Location permission denied');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(currentAddress: 'Location permanently denied');
        return;
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final address = await LocationUtils.getAddressFromCoordinates(position.latitude, position.longitude);

      state = state.copyWith(
        latitude: position.latitude,
        longitude: position.longitude,
        currentAddress: address,
      );
    } catch (e) {
      state = state.copyWith(currentAddress: 'Could not get location');
    }
  }

  static IconData _getServiceIcon(String n) {
    final l = n.toLowerCase();
    if (l.contains('electric')) return Icons.electrical_services;
    if (l.contains('plumb')) return Icons.plumbing;
    if (l.contains('appliance')) return Icons.kitchen;
    if (l.contains('ac')) return Icons.ac_unit;
    return Icons.build;
  }

  static Color _getServiceColor(String c) {
    final l = c.toLowerCase();
    if (l.contains('electric')) return Colors.blue;
    if (l.contains('plumb')) return Colors.cyan;
    if (l.contains('appliance')) return Colors.orange;
    if (l.contains('hvac') || l.contains('ac')) return Colors.green;
    return Colors.blue;
  }

  void dispose() {
    _servicesSubscription?.cancel();
    _techniciansSubscription?.cancel();
  }
}