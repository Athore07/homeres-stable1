// lib/presentation/screens/chat/chat_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../../routing/route_names.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  // Mock chat data
  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'John Doe',
      'lastMessage': 'I am on my way to your location',
      'time': DateTime.now().subtract(const Duration(minutes: 5)),
      'unread': 2,
      'avatar': null,
      'online': true,
      'bookingId': 'BK123',
    },
    {
      'name': 'Jane Smith',
      'lastMessage': 'Thank you for the great service!',
      'time': DateTime.now().subtract(const Duration(hours: 2)),
      'unread': 0,
      'avatar': null,
      'online': false,
      'bookingId': 'BK124',
    },
    {
      'name': 'Mike Johnson',
      'lastMessage': 'Can you confirm the booking for tomorrow?',
      'time': DateTime.now().subtract(const Duration(days: 1)),
      'unread': 1,
      'avatar': null,
      'online': true,
      'bookingId': 'BK125',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: _chats.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.chat_bubble_outline,
              title: 'No Messages',
              message: 'Your conversations with technicians will appear here.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _chats.length,
              itemBuilder: (context, index) {
                return _buildChatItem(context, _chats[index], index)
                    .animate()
                    .fadeIn(
                      duration: 400.ms,
                      delay: Duration(milliseconds: index * 100),
                    )
                    .slideX(begin: 20);
              },
            ),
    );
  }

  Widget _buildChatItem(BuildContext context, Map<String, dynamic> chat, int index) {
    final hasUnread = chat['unread'] > 0;
    
    return GestureDetector(
      onTap: () => context.push(
        RouteNames.chatDetail,
        extra: {
          'name': chat['name'],
          'bookingId': chat['bookingId'],
          'online': chat['online'],
        },
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: hasUnread
              ? Border.all(color: AppColors.primary.withOpacity(0.2))
              : null,
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    chat['name'][0],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                if (chat['online'])
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat['name'],
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      Text(
                        _formatChatTime(chat['time']),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: hasUnread
                              ? AppColors.primary
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat['lastMessage'],
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: hasUnread
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${chat['unread']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatChatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return DateFormat('HH:mm').format(dateTime);
    if (difference.inDays < 7) return DateFormat('EEE').format(dateTime);
    return DateFormat('MMM d').format(dateTime);
  }
}