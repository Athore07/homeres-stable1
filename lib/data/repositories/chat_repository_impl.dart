// lib/data/repositories/chat_repository_impl.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/chat_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore firestore;

  ChatRepositoryImpl({required this.firestore});

  @override
  Future<ChatEntity> createChat(String bookingId, List<String> participants) async {
    final docRef = firestore
        .collection(FirebaseConstants.chatsCollection)
        .doc();
    final chat = ChatEntity(
      id: docRef.id,
      participants: participants,
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      bookingId: bookingId,
      createdAt: DateTime.now(),
    );
    await docRef.set({
      'participants': participants,
      'lastMessage': '',
      'lastMessageTime': Timestamp.fromDate(DateTime.now()),
      'bookingId': bookingId,
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });
    return chat;
  }

  @override
  Future<void> sendMessage(ChatMessageEntity message) async {
    final messageRef = firestore
        .collection(FirebaseConstants.chatsCollection)
        .doc(message.chatId)
        .collection('messages')
        .doc();
    final messageModel = ChatMessageModel(
      id: messageRef.id,
      chatId: message.chatId,
      senderId: message.senderId,
      senderName: message.senderName,
      text: message.text,
      timestamp: message.timestamp,
    );
    await messageRef.set(messageModel.toFirestore());
    await firestore
        .collection(FirebaseConstants.chatsCollection)
        .doc(message.chatId)
        .update({
      'lastMessage': message.text,
      'lastMessageTime': Timestamp.fromDate(message.timestamp),
    });
  }

  @override
  Stream<List<ChatMessageEntity>> watchMessages(String chatId) {
    return firestore
        .collection(FirebaseConstants.chatsCollection)
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessageModel.fromFirestore(doc))
            .toList()
            .reversed
            .toList());
  }

  @override
  Future<List<ChatEntity>> getUserChats(String userId) async {
    final snapshot = await firestore
        .collection(FirebaseConstants.chatsCollection)
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ChatEntity(
        id: doc.id,
        participants: List<String>.from(data['participants'] ?? []),
        lastMessage: data['lastMessage'] ?? '',
        lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
        bookingId: data['bookingId'],
        createdAt: (data['createdAt'] as Timestamp).toDate(),
      );
    }).toList();
  }

  @override
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    final batch = firestore.batch();
    final snapshot = await firestore
        .collection(FirebaseConstants.chatsCollection)
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}