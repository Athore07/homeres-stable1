import 'package:dio/dio.dart';

abstract class ReviewRemoteDataSource {
  Future<List<ReviewModel>> getReviews(String productId);
  Future<ReviewModel> addReview(ReviewRequest request);
  Future<void> deleteReview(String reviewId);
  Future<ReviewModel> updateReview(String reviewId, ReviewRequest request);
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final Dio dio;
  static const String baseUrl = 'https://api.example.com';

  ReviewRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ReviewModel>> getReviews(String productId) async {
    try {
      final response = await dio.get('$baseUrl/products/$productId/reviews');
      return (response.data as List)
          .map((json) => ReviewModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch reviews: ${e.message}');
    }
  }

  @override
  Future<ReviewModel> addReview(ReviewRequest request) async {
    try {
      final response = await dio.post(
        '$baseUrl/reviews',
        data: request.toJson(),
      );
      return ReviewModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to add review: ${e.message}');
    }
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    try {
      await dio.delete('$baseUrl/reviews/$reviewId');
    } on DioException catch (e) {
      throw Exception('Failed to delete review: ${e.message}');
    }
  }

  @override
  Future<ReviewModel> updateReview(String reviewId, ReviewRequest request) async {
    try {
      final response = await dio.put(
        '$baseUrl/reviews/$reviewId',
        data: request.toJson(),
      );
      return ReviewModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to update review: ${e.message}');
    }
  }
}

class ReviewModel {
  final String id;
  final String productId;
  final String userId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      productId: json['productId'],
      userId: json['userId'],
      rating: json['rating'].toDouble(),
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ReviewRequest {
  final String productId;
  final String userId;
  final double rating;
  final String comment;

  ReviewRequest({
    required this.productId,
    required this.userId,
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'userId': userId,
      'rating': rating,
      'comment': comment,
    };
  }
}