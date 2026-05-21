// lib/presentation/providers/review/review_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/review_repository_impl.dart';
import '../../../domain/usecases/review/submit_review_usecase.dart';
import '../../../domain/usecases/review/get_reviews_usecase.dart';
import '../../../domain/usecases/review/get_technician_rating_usecase.dart';
import '../auth/auth_providers.dart';

// Provider for ReviewRepositoryImpl
final reviewRepositoryProvider = Provider<ReviewRepositoryImpl>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return ReviewRepositoryImpl(firestore: firestore);
});

// Provider for SubmitReviewUseCase
final submitReviewUseCaseProvider = Provider<SubmitReviewUseCase>((ref) {
  final repository = ref.watch(reviewRepositoryProvider);
  return SubmitReviewUseCase(repository);
});

// Provider for GetReviewsUseCase
final getReviewsUseCaseProvider = Provider<GetReviewsUseCase>((ref) {
  final repository = ref.watch(reviewRepositoryProvider);
  return GetReviewsUseCase(repository);
});

// Provider for GetTechnicianRatingUseCase
final getTechnicianRatingUseCaseProvider = Provider<GetTechnicianRatingUseCase>((ref) {
  final repository = ref.watch(reviewRepositoryProvider);
  return GetTechnicianRatingUseCase(repository);
});