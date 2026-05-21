// lib/presentation/providers/homeowner/booking_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/firebase_service.dart';

part 'booking_provider.g.dart';

class BookingState {
  final int currentStep;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final String selectedService;
  final String description;
  final String address;
  final bool isEmergency;
  final double estimatedPrice;
  final bool isSubmitting;
  final String? error;
  final List<String> services;
  final String technicianName;
  final String technicianId;
  final double technicianRate;

  const BookingState({
    this.currentStep = 0,
    required this.selectedDate,
    this.selectedTime = const TimeOfDay(hour: 9, minute: 0),
    this.selectedService = '',
    this.description = '',
    this.address = '',
    this.isEmergency = false,
    this.estimatedPrice = 0.0,
    this.isSubmitting = false,
    this.error,
    this.services = const [],
    this.technicianName = '',
    this.technicianId = '',
    this.technicianRate = 0.0,
  });

  BookingState copyWith({
    int? currentStep,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    String? selectedService,
    String? description,
    String? address,
    bool? isEmergency,
    double? estimatedPrice,
    bool? isSubmitting,
    String? error,
    List<String>? services,
    String? technicianName,
    String? technicianId,
    double? technicianRate,
  }) {
    return BookingState(
      currentStep: currentStep ?? this.currentStep,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      selectedService: selectedService ?? this.selectedService,
      description: description ?? this.description,
      address: address ?? this.address,
      isEmergency: isEmergency ?? this.isEmergency,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      services: services ?? this.services,
      technicianName: technicianName ?? this.technicianName,
      technicianId: technicianId ?? this.technicianId,
      technicianRate: technicianRate ?? this.technicianRate,
    );
  }
}

@riverpod
class BookingNotifier extends _$BookingNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  BookingState build() {
    _loadServices();
    return BookingState(selectedDate: DateTime.now().add(const Duration(days: 1)));
  }

  void init(Map<String, dynamic> extra) {
    state = state.copyWith(
      technicianName: extra['name'] as String? ?? '',
      technicianId: extra['id'] as String? ?? '',
      technicianRate: (extra['hourlyRate'] as num?)?.toDouble() ?? 0.0,
      selectedService: extra['specialty'] as String? ?? '',
    );
    _calcPrice();
  }

  void nextStep() => state = state.copyWith(currentStep: state.currentStep + 1);
  void prevStep() => state = state.copyWith(currentStep: state.currentStep - 1);
  void setService(String s) { state = state.copyWith(selectedService: s); _calcPrice(); }
  void setDate(DateTime d) => state = state.copyWith(selectedDate: d);
  void setTime(TimeOfDay t) => state = state.copyWith(selectedTime: t);
  void setDescription(String d) => state = state.copyWith(description: d);
  void setAddress(String a) => state = state.copyWith(address: a);
  void toggleEmergency(bool e) { state = state.copyWith(isEmergency: e); _calcPrice(); }

  void _calcPrice() {
    double base = 50.0;
    if (state.selectedService.toLowerCase().contains('ac')) base = 60.0;
    if (state.selectedService.toLowerCase().contains('appliance')) base = 55.0;
    if (state.isEmergency) base += 25.0;
    state = state.copyWith(estimatedPrice: base + 10.0);
  }

  Future<void> _loadServices() async {
    try {
      final snapshot = await _firebaseService.servicesRef.where('isActive', isEqualTo: true).get();
      state = state.copyWith(services: snapshot.docs.map((d) => (d.data() as Map<String, dynamic>)['name'] as String? ?? '').where((n) => n.isNotEmpty).toList());
    } catch (_) {}
  }

  Future<bool> submitBooking(String userId) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final date = DateTime(state.selectedDate.year, state.selectedDate.month, state.selectedDate.day, state.selectedTime.hour, state.selectedTime.minute);
      await _firebaseService.bookingsRef.add({
        'homeownerId': userId,
        'technicianId': state.technicianId,
        'serviceId': '',
        'serviceName': state.selectedService,
        'scheduledTime': Timestamp.fromDate(date),
        'status': 'pending',
        'address': state.address,
        'location': const GeoPoint(-6.369028, 34.888822),
        'description': state.description,
        'totalPrice': state.estimatedPrice,
        'isEmergency': state.isEmergency,
        'createdAt': FieldValue.serverTimestamp(),
      });
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }
}