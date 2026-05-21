// lib/presentation/providers/booking/booking_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/booking_repository_impl.dart';
import '../../../domain/usecases/booking/booking_usecase.dart';
import '../auth/auth_providers.dart';

// Provider for BookingRepositoryImpl
final bookingRepositoryProvider = Provider<BookingRepositoryImpl>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return BookingRepositoryImpl(firestore: firestore);
});

// Provider for BookingUseCase (combined)
final bookingUseCaseProvider = Provider<BookingUseCase>((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  return BookingUseCase(repository);
});