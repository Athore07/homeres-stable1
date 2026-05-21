// lib/domain/entities/chat_message.dart
class ChatMessageEntity {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String text;
  final String? imageUrl;
  final bool isRead;
  final DateTime timestamp;

  const ChatMessageEntity({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.text,
    this.imageUrl,
    this.isRead = false,
    required this.timestamp,
  });
}