// lib/domain/entities/chat.dart
class ChatEntity {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String? bookingId;
  final DateTime createdAt;

  const ChatEntity({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    this.bookingId,
    required this.createdAt,
  });
}