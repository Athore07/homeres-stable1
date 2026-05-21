// lib/domain/usecases/review/get_reviews_usecase.dart
import '../../entities/review.dart';
import '../../repositories/review_repository.dart';

class GetReviewsUseCase {
  final ReviewRepository repository;

  GetReviewsUseCase(this.repository);

  Future<List<ReviewEntity>> call(String technicianId) async {
    return await repository.getTechnicianReviews(technicianId);
  }
}