// lib/domain/entities/notification.dart
import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final String? referenceId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.referenceId,
    this.isRead = false,
    required this.createdAt,
    this.readAt,
  });

  NotificationEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? type,
    String? referenceId,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      referenceId: referenceId ?? this.referenceId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        message,
        type,
        referenceId,
        isRead,
        createdAt,
        readAt,
      ];

  @override
  String toString() {
    return 'NotificationEntity(id: $id, title: $title, type: $type, isRead: $isRead)';
  }
}