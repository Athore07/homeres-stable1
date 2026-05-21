// lib/domain/usecases/review/submit_review_usecase.dart
import '../../entities/review.dart';
import '../../repositories/review_repository.dart';

class SubmitReviewUseCase {
  final ReviewRepository repository;

  SubmitReviewUseCase(this.repository);

  Future<void> call(ReviewEntity review) async {
    await repository.submitReview(review);
  }
}
