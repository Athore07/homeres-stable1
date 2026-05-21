// lib/data/models/review_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/review.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.bookingId,
    required super.userId,
    required super.technicianId,
    required super.userName,
    required super.rating,
    super.comment,
    super.wouldRecommend = true,
    required super.createdAt,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      bookingId: data['bookingId'] ?? '',
      userId: data['userId'] ?? '',
      technicianId: data['technicianId'] ?? '',
      userName: data['userName'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      comment: data['comment'],
      wouldRecommend: data['wouldRecommend'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'bookingId': bookingId,
    'userId': userId,
    'technicianId': technicianId,
    'userName': userName,
    'rating': rating,
    'comment': comment,
    'wouldRecommend': wouldRecommend,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory ReviewModel.fromEntity(ReviewEntity entity) {
    return ReviewModel(
      id: entity.id,
      bookingId: entity.bookingId,
      userId: entity.userId,
      technicianId: entity.technicianId,
      userName: entity.userName,
      rating: entity.rating,
      comment: entity.comment,
      wouldRecommend: entity.wouldRecommend,
      createdAt: entity.createdAt,
    );
  }
}