// lib/presentation/providers/review/review_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/review.dart';
import 'review_providers.dart';

part 'review_provider.g.dart';

// Review State
class ReviewState {
  final List<ReviewEntity> reviews;
  final bool isLoading;
  final String? error;
  final double averageRating;
  final int totalReviews;

  const ReviewState({
    this.reviews = const [],
    this.isLoading = false,
    this.error,
    this.averageRating = 0.0,
    this.totalReviews = 0,
  });

  ReviewState copyWith({
    List<ReviewEntity>? reviews,
    bool? isLoading,
    String? error,
    double? averageRating,
    int? totalReviews,
  }) {
    return ReviewState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
    );
  }

  factory ReviewState.initial() => const ReviewState();
}

@riverpod
class ReviewNotifier extends _$ReviewNotifier {
  @override
  ReviewState build() {
    return ReviewState.initial();
  }

  Future<void> loadTechnicianReviews(String technicianId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final getReviewsUseCase = ref.read(getReviewsUseCaseProvider);
      final getRatingUseCase = ref.read(getTechnicianRatingUseCaseProvider);
      
      final reviews = await getReviewsUseCase(technicianId);
      final rating = await getRatingUseCase(technicianId);
      
      state = ReviewState(
        reviews: reviews,
        averageRating: rating,
        totalReviews: reviews.length,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<bool> submitReview({
    required String bookingId,
    required String userId,
    required String technicianId,
    required String userName,
    required double rating,
    String? comment,
    bool wouldRecommend = true,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final submitReviewUseCase = ref.read(submitReviewUseCaseProvider);
      
      final review = ReviewEntity(
        id: const Uuid().v4(),
        bookingId: bookingId,
        userId: userId,
        technicianId: technicianId,
        userName: userName,
        rating: rating,
        comment: comment,
        wouldRecommend: wouldRecommend,
        createdAt: DateTime.now(),
      );
      
      await submitReviewUseCase(review);
      await loadTechnicianReviews(technicianId);
      
      return true;
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to submit review: ${e.toString()}',
        isLoading: false,
      );
      return false;
    }
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}