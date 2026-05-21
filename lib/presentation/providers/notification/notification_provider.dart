// lib/presentation/providers/notification/notification_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../../../core/services/firebase_service.dart';
import '../../../domain/entities/notification.dart';

part 'notification_provider.g.dart';

// State class
class NotificationState {
  final List<NotificationEntity> allNotifications;
  final List<NotificationEntity> filteredNotifications;
  final String selectedFilter;
  final bool isLoading;
  final String? error;

  const NotificationState({
    this.allNotifications = const [],
    this.filteredNotifications = const [],
    this.selectedFilter = 'All',
    this.isLoading = false,
    this.error,
  });

  int get unreadCount => allNotifications.where((n) => !n.isRead).length;

  List<String> get filters => ['All', 'Unread', 'Booking', 'Chat', 'Payment'];

  NotificationState copyWith({
    List<NotificationEntity>? allNotifications,
    List<NotificationEntity>? filteredNotifications,
    String? selectedFilter,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      allNotifications: allNotifications ?? this.allNotifications,
      filteredNotifications: filteredNotifications ?? this.filteredNotifications,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

@riverpod
class NotificationNotifier extends _$NotificationNotifier {
  StreamSubscription<QuerySnapshot>? _subscription;

  @override
  NotificationState build() {
    // Start listening when provider is first used
    ref.onDispose(() {
      _subscription?.cancel();
    });
    
    // Load notifications after build
    Future.microtask(() => _startListening());
    
    return const NotificationState();
  }

  FirebaseService get _firebaseService => FirebaseService();

  // Start real-time listener
  Future<void> _startListening() async {
    final user = _firebaseService.currentUser;
    
    if (user == null) {
      state = state.copyWith(error: 'User not authenticated', isLoading: false);
      return;
    }

    // Cancel existing subscription
    await _subscription?.cancel();
    state = state.copyWith(isLoading: true, error: null);

    try {
      _subscription = _firebaseService.notificationsRef
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .listen(
            (snapshot) {
              final notifications = snapshot.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return NotificationEntity(
                  id: doc.id,
                  userId: data['userId'] as String? ?? '',
                  title: data['title'] as String? ?? '',
                  message: data['message'] as String? ?? '',
                  type: data['type'] as String? ?? '',
                  referenceId: data['referenceId'] as String?,
                  isRead: data['isRead'] as bool? ?? false,
                  createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                  readAt: (data['readAt'] as Timestamp?)?.toDate(),
                );
              }).toList();
              _updateNotifications(notifications);
            },
            onError: (error) {
              state = state.copyWith(
                error: 'Error loading notifications: $error',
                isLoading: false,
              );
            },
          );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to start notification listener: $e',
        isLoading: false,
      );
    }
  }

  void _updateNotifications(List<NotificationEntity> notifications) {
    state = state.copyWith(allNotifications: notifications);
    _applyFilter(state.selectedFilter);
  }

  void setFilter(String filter) {
    if (!state.filters.contains(filter)) return;
    state = state.copyWith(selectedFilter: filter);
    _applyFilter(filter);
  }

  void _applyFilter(String filter) {
    List<NotificationEntity> filtered;
    
    switch (filter) {
      case 'Unread':
        filtered = state.allNotifications.where((n) => !n.isRead).toList();
        break;
      case 'Booking':
        filtered = state.allNotifications.where((n) => n.type.toLowerCase() == 'booking').toList();
        break;
      case 'Chat':
        filtered = state.allNotifications.where((n) => n.type.toLowerCase() == 'chat').toList();
        break;
      case 'Payment':
        filtered = state.allNotifications.where((n) => n.type.toLowerCase() == 'payment').toList();
        break;
      default: // 'All'
        filtered = List.from(state.allNotifications);
    }
    
    state = state.copyWith(
      filteredNotifications: filtered,
      isLoading: false,
    );
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firebaseService.notificationsRef.doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
      // The Firestore listener will automatically update the state
    } catch (e) {
      // Fallback: update locally if Firestore update fails
      final updatedNotifications = state.allNotifications.map((n) {
        if (n.id == notificationId && !n.isRead) {
          return NotificationEntity(
            id: n.id,
            userId: n.userId,
            title: n.title,
            message: n.message,
            type: n.type,
            referenceId: n.referenceId,
            isRead: true,
            createdAt: n.createdAt,
            readAt: DateTime.now(),
          );
        }
        return n;
      }).toList();
      
      state = state.copyWith(allNotifications: updatedNotifications);
      _applyFilter(state.selectedFilter);
    }
  }

  Future<void> markAllAsRead() async {
    final unreadNotifications = state.allNotifications.where((n) => !n.isRead).toList();
    
    if (unreadNotifications.isEmpty) return;
    
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (final notification in unreadNotifications) {
        batch.update(_firebaseService.notificationsRef.doc(notification.id), {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      // The Firestore listener will automatically update the state
    } catch (e) {
      // Fallback: update locally
      final updatedNotifications = state.allNotifications.map((n) {
        if (!n.isRead) {
          return NotificationEntity(
            id: n.id,
            userId: n.userId,
            title: n.title,
            message: n.message,
            type: n.type,
            referenceId: n.referenceId,
            isRead: true,
            createdAt: n.createdAt,
            readAt: DateTime.now(),
          );
        }
        return n;
      }).toList();
      
      state = state.copyWith(allNotifications: updatedNotifications);
      _applyFilter(state.selectedFilter);
    }
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }
}