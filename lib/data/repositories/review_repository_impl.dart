// lib/data/repositories/review_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../models/review_model.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final FirebaseFirestore firestore;

  ReviewRepositoryImpl({required this.firestore});

  @override
  Future<List<ReviewEntity>> getTechnicianReviews(String technicianId) async {
    final snapshot = await firestore
        .collection(FirebaseConstants.reviewsCollection)
        .where('technicianId', isEqualTo: technicianId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<ReviewEntity>> getUserReviews(String userId) async {
    final snapshot = await firestore
        .collection(FirebaseConstants.reviewsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> submitReview(ReviewEntity review) async {
    final reviewModel = ReviewModel.fromEntity(review);
    await firestore
        .collection(FirebaseConstants.reviewsCollection)
        .doc(review.id)
        .set(reviewModel.toFirestore());
    
    // Update technician rating
    await _updateTechnicianRating(review.technicianId);
  }

  @override
  Future<double> getTechnicianRating(String technicianId) async {
    final snapshot = await firestore
        .collection(FirebaseConstants.reviewsCollection)
        .where('technicianId', isEqualTo: technicianId)
        .get();
    
    if (snapshot.docs.isEmpty) return 0.0;
    
    final totalRating = snapshot.docs.fold<double>(
      0.0,
      (sum, doc) => sum + ((doc.data()['rating'] as num?)?.toDouble() ?? 0.0),
    );
    return totalRating / snapshot.docs.length;
  }

  @override
  Future<bool> hasUserReviewed(String bookingId, String userId) async {
    final snapshot = await firestore
        .collection(FirebaseConstants.reviewsCollection)
        .where('bookingId', isEqualTo: bookingId)
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  @override
  Stream<List<ReviewEntity>> watchTechnicianReviews(String technicianId) {
    return firestore
        .collection(FirebaseConstants.reviewsCollection)
        .where('technicianId', isEqualTo: technicianId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromFirestore(doc))
            .toList());
  }

  Future<void> _updateTechnicianRating(String technicianId) async {
    final rating = await getTechnicianRating(technicianId);
    final totalReviews = await firestore
        .collection(FirebaseConstants.reviewsCollection)
        .where('technicianId', isEqualTo: technicianId)
        .count()
        .get();
    
    await firestore
        .collection(FirebaseConstants.techniciansCollection)
        .doc(technicianId)
        .update({
          'rating': double.parse(rating.toStringAsFixed(1)),
          'totalReviews': totalReviews.count,
        });
  }
}