// lib/presentation/providers/homeowner/service_list_provider.dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:async';
import '../../../core/services/firebase_service.dart';

part 'service_list_provider.g.dart';

class ServiceListState {
  final List<Map<String, dynamic>> services;
  final List<Map<String, dynamic>> technicians;
  final String selectedCategory;
  final bool isGridView;
  final bool isLoading;
  final String? error;

  const ServiceListState({
    this.services = const [],
    this.technicians = const [],
    this.selectedCategory = 'All',
    this.isGridView = true,
    this.isLoading = false,
    this.error,
  });

  List<String> get categories {
    final cats = services.map((s) => s['category'] as String).toSet().toList()..sort();
    return ['All', ...cats];
  }

  List<Map<String, dynamic>> get filteredServices {
    if (selectedCategory == 'All') return services;
    return services.where((s) => s['category'] == selectedCategory).toList();
  }

  ServiceListState copyWith({
    List<Map<String, dynamic>>? services, List<Map<String, dynamic>>? technicians,
    String? selectedCategory, bool? isGridView, bool? isLoading, String? error,
  }) {
    return ServiceListState(
      services: services ?? this.services, technicians: technicians ?? this.technicians,
      selectedCategory: selectedCategory ?? this.selectedCategory, isGridView: isGridView ?? this.isGridView,
      isLoading: isLoading ?? this.isLoading, error: error,
    );
  }
}

@riverpod
class ServiceListNotifier extends _$ServiceListNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription? _servicesSubscription;
  StreamSubscription? _techniciansSubscription;

  @override
  ServiceListState build() {
    Future.microtask(() => _startListening());
    return const ServiceListState();
  }

  void setCategory(String c) => state = state.copyWith(selectedCategory: c);
  void toggleView() => state = state.copyWith(isGridView: !state.isGridView);

  // Start all real-time listeners
  void _startListening() {
    _listenToServices();
    _listenToTechnicians();
  }

  // Stop all listeners
  void stopListening() {
    _servicesSubscription?.cancel();
    _techniciansSubscription?.cancel();
  }

  // Real-time services listener
  void _listenToServices() {
    _servicesSubscription?.cancel();
    state = state.copyWith(isLoading: true, error: null);

    _servicesSubscription = _firebaseService.servicesRef
        .snapshots()
        .listen(
          (snapshot) {
            final services = snapshot.docs.map<Map<String, dynamic>>((doc) {
              final d = doc.data() as Map<String, dynamic>? ?? {};
              return {
                'id': doc.id,
                'name': d['name'] ?? '',
                'icon': _icon(d['name'] ?? ''),
                'color': _color(d['category'] ?? ''),
                'category': d['category'] ?? 'General',
                'description': d['description'] ?? '',
                'basePrice': (d['basePrice'] as num?)?.toDouble() ?? 0.0,
              };
            }).toList();
            state = state.copyWith(services: services, isLoading: false);
          },
          onError: (e) => state = state.copyWith(isLoading: false, error: e.toString()),
        );
  }

  // Real-time technicians listener
  void _listenToTechnicians() {
    _techniciansSubscription?.cancel();

    _techniciansSubscription = _firebaseService.techniciansRef
        .where('verificationStatus', isEqualTo: 'verified')
        .snapshots()
        .listen(
          (snapshot) {
            final technicians = snapshot.docs.map<Map<String, dynamic>>((doc) {
              final d = doc.data() as Map<String, dynamic>? ?? {};
              return {
                'id': doc.id,
                'name': d['name'] ?? 'Unknown',
                'specialty': d['specialty'] ?? 'General',
                'rating': (d['rating'] as num?)?.toDouble() ?? 0.0,
                'totalJobs': (d['totalJobs'] as num?)?.toInt() ?? 0,
                'hourlyRate': (d['hourlyRate'] as num?)?.toDouble() ?? 0.0,
                'isAvailable': d['isAvailable'] == true,
              };
            }).toList();
            state = state.copyWith(technicians: technicians);
          },
          onError: (e) => state = state.copyWith(error: e.toString()),
        );
  }

  // Refresh manually (reconnect listeners)
  Future<void> refresh() async {
    _startListening();
  }

  static IconData _icon(String n) {
    final l = n.toLowerCase();
    if (l.contains('electric')) return Icons.electrical_services;
    if (l.contains('plumb')) return Icons.plumbing;
    if (l.contains('appliance')) return Icons.kitchen;
    if (l.contains('ac') || l.contains('hvac')) return Icons.ac_unit;
    if (l.contains('carpent')) return Icons.carpenter;
    if (l.contains('paint')) return Icons.format_paint;
    return Icons.build;
  }

  static Color _color(String c) {
    final l = c.toLowerCase();
    if (l.contains('electric')) return Colors.blue;
    if (l.contains('plumb')) return Colors.cyan;
    if (l.contains('appliance')) return Colors.orange;
    if (l.contains('hvac') || l.contains('ac')) return Colors.green;
    if (l.contains('carpent')) return Colors.brown;
    if (l.contains('paint')) return Colors.purple;
    return Colors.blue;
  }

  void dispose() {
    _servicesSubscription?.cancel();
    _techniciansSubscription?.cancel();
  }
}