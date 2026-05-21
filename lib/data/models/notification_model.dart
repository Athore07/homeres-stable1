// lib/data/models/notification_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.message,
    required super.type,
    super.referenceId,
    super.isRead = false,
    required super.createdAt,
    super.readAt,
  });

  // Factory method to create from Firestore DocumentSnapshot
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      message: data['message'] as String? ?? '',
      type: data['type'] as String? ?? 'system',
      referenceId: data['referenceId'] as String?,
      isRead: data['isRead'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
    );
  }

  // Factory method to create from QueryDocumentSnapshot
  factory NotificationModel.fromQuerySnapshot(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      message: data['message'] as String? ?? '',
      type: data['type'] as String? ?? 'system',
      referenceId: data['referenceId'] as String?,
      isRead: data['isRead'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
    );
  }

  // Factory method to create from Map (for testing or local storage)
  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      message: map['message'] as String? ?? '',
      type: map['type'] as String? ?? 'system',
      referenceId: map['referenceId'] as String?,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: (map['createdAt'] as DateTime?) ?? DateTime.now(),
      readAt: map['readAt'] as DateTime?,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'referenceId': referenceId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      if (readAt != null) 'readAt': Timestamp.fromDate(readAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Convert to Map (for local storage or API)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'referenceId': referenceId,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
    };
  }

  // Create a copy with updated fields
  NotificationModel copyWith({
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
    return NotificationModel(
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

  // Convert to Entity
  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      userId: userId,
      title: title,
      message: message,
      type: type,
      referenceId: referenceId,
      isRead: isRead,
      createdAt: createdAt,
      readAt: readAt,
    );
  }

  // Create from Entity
  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      message: entity.message,
      type: entity.type,
      referenceId: entity.referenceId,
      isRead: entity.isRead,
      createdAt: entity.createdAt,
      readAt: entity.readAt,
    );
  }

  // Batch create from list of documents
  static List<NotificationModel> fromFirestoreBatch(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) => NotificationModel.fromFirestore(doc)).toList();
  }

  // Validation method
  bool isValid() {
    return id.isNotEmpty &&
        userId.isNotEmpty &&
        title.isNotEmpty &&
        message.isNotEmpty &&
        type.isNotEmpty;
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, userId: $userId, title: $title, type: $type, isRead: $isRead, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.message == message &&
        other.type == type &&
        other.referenceId == referenceId &&
        other.isRead == isRead &&
        other.createdAt == createdAt &&
        other.readAt == readAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      title,
      message,
      type,
      referenceId,
      isRead,
      createdAt,
      readAt,
    );
  }
}

// Extension for converting lists
extension NotificationModelListExtension on List<NotificationModel> {
  List<NotificationEntity> toEntities() {
    return map((model) => model.toEntity()).toList();
  }

  List<Map<String, dynamic>> toMaps() {
    return map((model) => model.toMap()).toList();
  }
}