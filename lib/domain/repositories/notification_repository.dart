// lib/domain/repositories/notification_repository.dart
import '../entities/notification.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getUserNotifications(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
  Future<int> getUnreadCount(String userId);
  Stream<List<NotificationEntity>> watchNotifications(String userId);
}
