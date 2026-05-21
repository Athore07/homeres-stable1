// lib/domain/entities/review.dart
class ReviewEntity {
  final String id;
  final String bookingId;
  final String userId;
  final String technicianId;
  final String userName;
  final double rating;
  final String? comment;
  final bool wouldRecommend;
  final DateTime createdAt;

  const ReviewEntity({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.technicianId,
    required this.userName,
    required this.rating,
    this.comment,
    this.wouldRecommend = true,
    required this.createdAt,
  });
}