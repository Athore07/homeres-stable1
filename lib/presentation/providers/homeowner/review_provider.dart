// lib/presentation/providers/homeowner/review_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/firebase_service.dart';

part 'review_provider.g.dart';

class ReviewState {
  final String technicianName;
  final String technicianId;
  final String bookingId;
  final String serviceName;
  final double rating;
  final String comment;
  final bool wouldRecommend;
  final List<String> feedback;
  final Map<String, double> qualityRatings;
  final bool isSubmitting;
  final bool isSuccess;
  final String? error;

  const ReviewState({
    this.technicianName = '',
    this.technicianId = '',
    this.bookingId = '',
    this.serviceName = '',
    this.rating = 0,
    this.comment = '',
    this.wouldRecommend = true,
    this.feedback = const [],
    this.qualityRatings = const {},
    this.isSubmitting = false,
    this.isSuccess = false,
    this.error,
  });

  ReviewState copyWith({
    String? technicianName, String? technicianId, String? bookingId, String? serviceName,
    double? rating, String? comment, bool? wouldRecommend, List<String>? feedback,
    Map<String, double>? qualityRatings, bool? isSubmitting, bool? isSuccess, String? error,
  }) {
    return ReviewState(
      technicianName: technicianName ?? this.technicianName,
      technicianId: technicianId ?? this.technicianId,
      bookingId: bookingId ?? this.bookingId,
      serviceName: serviceName ?? this.serviceName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      wouldRecommend: wouldRecommend ?? this.wouldRecommend,
      feedback: feedback ?? this.feedback,
      qualityRatings: qualityRatings ?? this.qualityRatings,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
    );
  }
}

@riverpod
class ReviewNotifier extends _$ReviewNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  static const _feedbackOptions = ['Punctual', 'Professional', 'Quality Work', 'Friendly', 'Clean', 'Good Value', 'Knowledgeable', 'Efficient'];
  static const _qualityLabels = ['Quality of Work', 'Professionalism', 'Punctuality', 'Communication'];

  List<String> get feedbackOptions => _feedbackOptions;
  List<String> get qualityLabels => _qualityLabels;

  @override
  ReviewState build() => const ReviewState();

  Future<void> init(Map<String, dynamic> extra) async {
    final techId = extra['technicianId'] as String? ?? '';
    final bookingId = extra['bookingId'] as String? ?? '';

    state = state.copyWith(technicianId: techId, bookingId: bookingId, serviceName: extra['serviceName'] as String? ?? '');

    if (techId.isNotEmpty) {
      try {
        final doc = await _firebaseService.techniciansRef.doc(techId).get();
        if (doc.exists) {
          final d = doc.data() as Map<String, dynamic>? ?? {};
          state = state.copyWith(technicianName: d['name'] as String? ?? 'Technician');
        }
      } catch (_) {}
    }
  }

  void setRating(double r) => state = state.copyWith(rating: r);
  void setComment(String c) => state = state.copyWith(comment: c);
  void setRecommend(bool r) => state = state.copyWith(wouldRecommend: r);

  void toggleFeedback(String f) {
    final list = List<String>.from(state.feedback);
    list.contains(f) ? list.remove(f) : list.add(f);
    state = state.copyWith(feedback: list);
  }

  void setQualityRating(String label, double r) {
    final map = Map<String, double>.from(state.qualityRatings);
    map[label] = r;
    state = state.copyWith(qualityRatings: map);
  }

  Future<bool> submit(String userId, String userName) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      await _firebaseService.reviewsRef.add({
        'bookingId': state.bookingId,
        'userId': userId,
        'userName': userName,
        'technicianId': state.technicianId,
        'rating': state.rating,
        'comment': state.comment.isNotEmpty ? state.comment : null,
        'wouldRecommend': state.wouldRecommend,
        'feedback': state.feedback,
        'qualityRatings': state.qualityRatings,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update technician average rating
      if (state.technicianId.isNotEmpty) {
        final reviews = await _firebaseService.reviewsRef.where('technicianId', isEqualTo: state.technicianId).get();
        double total = 0;
        for (final r in reviews.docs) total += (r['rating'] as num?)?.toDouble() ?? 0;
        final avg = reviews.size > 0 ? total / reviews.size : 0;
        await _firebaseService.techniciansRef.doc(state.technicianId).update({'rating': double.parse(avg.toStringAsFixed(1)), 'totalReviews': reviews.size});
      }

      state = state.copyWith(isSubmitting: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }
}