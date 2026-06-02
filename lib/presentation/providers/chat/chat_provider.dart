// lib/presentation/providers/chat/chat_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:async';
import '../../../core/services/firebase_service.dart';

class ChatState extends ChangeNotifier {
  List<Map<String, dynamic>> _chats = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get chats => _chats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription? _subscription;

  void startListening(String userId) {
    _subscription?.cancel();
    
    _subscription = _firebaseService.chatsRef
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            final chats = snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'id': doc.id,
                'name': data['otherUserName'] ?? 'Chat',
                'lastMessage': data['lastMessage'] ?? '',
                'time': (data['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
                'unread': data['unreadCount'] ?? 0,
                'bookingId': data['bookingId'] ?? '',
                'online': data['otherUserOnline'] ?? false,
                'avatar': data['otherUserAvatar'] as String?,
              };
            }).toList();
            _chats = chats;
            notifyListeners();
          },
          onError: (e) {
            _error = e.toString();
            notifyListeners();
          },
        );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> sendMessage(String chatId, String text, String senderId) async {
    if (text.trim().isEmpty) return;
    
    try {
      await _firebaseService.chatsRef.doc(chatId).collection('messages').add({
        'text': text,
        'sender': senderId,
        'time': FieldValue.serverTimestamp(),
        'read': false,
      });
      
      await _firebaseService.chatsRef.doc(chatId).update({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}

final chatProvider = ChangeNotifierProvider<ChatState>((ref) {
  return ChatState();
});