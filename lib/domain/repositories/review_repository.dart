// lib/domain/repositories/review_repository.dart
import '../entities/review.dart';

abstract class ReviewRepository {
  Future<List<ReviewEntity>> getTechnicianReviews(String technicianId);
  Future<List<ReviewEntity>> getUserReviews(String userId);
  Future<void> submitReview(ReviewEntity review);
  Future<double> getTechnicianRating(String technicianId);
  Future<bool> hasUserReviewed(String bookingId, String userId);
  Stream<List<ReviewEntity>> watchTechnicianReviews(String technicianId);
}
