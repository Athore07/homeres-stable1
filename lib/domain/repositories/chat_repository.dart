// lib/domain/repositories/chat_repository.dart
import '../entities/chat_message.dart';
import '../entities/chat.dart';

abstract class ChatRepository {
  Future<ChatEntity> createChat(String bookingId, List<String> participants);
  Future<void> sendMessage(ChatMessageEntity message);
  Stream<List<ChatMessageEntity>> watchMessages(String chatId);
  Future<List<ChatEntity>> getUserChats(String userId);
  Future<void> markMessagesAsRead(String chatId, String userId);
}

