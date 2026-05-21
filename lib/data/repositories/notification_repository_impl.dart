// lib/data/repositories/notification_repository_impl.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFirestore firestore;

  NotificationRepositoryImpl({required this.firestore});

  @override
  Future<List<NotificationEntity>> getUserNotifications(String userId) async {
    final snapshot = await firestore
        .collection(FirebaseConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    return snapshot.docs
        .map((doc) => NotificationModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await firestore
        .collection(FirebaseConstants.notificationsCollection)
        .doc(notificationId)
        .update({'isRead': true});
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final batch = firestore.batch();
    final snapshot = await firestore
        .collection(FirebaseConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    final snapshot = await firestore
        .collection(FirebaseConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  @override
  Stream<List<NotificationEntity>> watchNotifications(String userId) {
    return firestore
        .collection(FirebaseConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }
}