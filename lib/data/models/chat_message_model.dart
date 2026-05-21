// lib/data/models/chat_message_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.chatId,
    required super.senderId,
    required super.senderName,
    required super.text,
    super.imageUrl,
    super.isRead = false,
    required super.timestamp,
  });

  factory ChatMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessageModel(
      id: doc.id,
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      text: data['text'] ?? '',
      imageUrl: data['imageUrl'],
      isRead: data['isRead'] ?? false,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'chatId': chatId,
    'senderId': senderId,
    'senderName': senderName,
    'text': text,
    'imageUrl': imageUrl,
    'isRead': isRead,
    'timestamp': Timestamp.fromDate(timestamp),
  };
}