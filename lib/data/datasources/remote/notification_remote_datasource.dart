import 'package:dio/dio.dart';

abstract class NotificationRemoteDatasource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> deleteNotification(String notificationId);
}

class NotificationRemoteDatasourceImpl implements NotificationRemoteDatasource {
  final Dio dio;
  static const String baseUrl = '/api/notifications';

  NotificationRemoteDatasourceImpl({required this.dio});

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await dio.get(baseUrl);
      final list = (response.data as List)
          .map((e) => NotificationModel.fromJson(e))
          .toList();
      return list;
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await dio.patch('$baseUrl/$notificationId/read');
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await dio.delete('$baseUrl/$notificationId');
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}