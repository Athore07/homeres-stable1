// lib/presentation/screens/notifications/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../domain/entities/notification.dart';
import '../../providers/notification/notification_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/custom_button.dart';
import '../../../routing/route_names.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Real-time listener starts automatically via provider
  }

  @override
  void dispose() {
    // Stop listener when leaving screen
    ref.read(notificationProvider.notifier).stopListening();
    super.dispose();
  }

  void _handleTap(BuildContext context, NotificationEntity n) {
    switch (n.type) {
      case 'booking':
        if (n.referenceId != null) {
          context.push(RouteNames.bookingDetail, extra: {'bookingId': n.referenceId});
        }
        break;
      case 'chat':
        if (n.referenceId != null) {
          context.push(RouteNames.chatDetail, extra: {'chatId': n.referenceId});
        }
        break;
      case 'payment':
        context.push(RouteNames.invoice);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Use correct generated provider name
    final state = ref.watch(notificationProvider);
    final notifier = ref.read(notificationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: () {
                notifier.markAllAsRead();
                context.showSnackBar('All marked as read');
              },
              child: Text('Mark All Read', style: TextStyle(fontSize: 13, color: Colors.white)),
            ),
        ],
      ),
      body: state.isLoading && state.allNotifications.isEmpty
          ? const _Shimmer()
          : state.error != null
              ? _ErrorView(message: state.error!, onRetry: () {},)
              : Column(children: [
                  _FilterChips(
                    filters: ['All', 'Unread', 'Booking', 'Chat', 'Payment'],
                    selected: state.selectedFilter,
                    onChanged: notifier.setFilter,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(children: [
                      Text('${state.unreadCount} unread', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                    ]),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: state.filteredNotifications.isEmpty
                        ? const EmptyStateWidget(
                            icon: Icons.notifications_none,
                            title: 'No Notifications',
                            message: 'You\'re all caught up!',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: state.filteredNotifications.length,
                            itemBuilder: (_, i) => _NotificationCard(
                              notification: state.filteredNotifications[i],
                              onTap: (n) {
                                if (!n.isRead) notifier.markAsRead(n.id);
                                _handleTap(context, n);
                              },
                            ),
                          ),
                  ),
                ]),
    );
  }
}

// ==================== Filter Chips ====================
class _FilterChips extends StatelessWidget {
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onChanged;

  const _FilterChips({required this.filters, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: filters.map((f) {
          final isSelected = selected == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ==================== Notification Card ====================
class _NotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final ValueChanged<NotificationEntity> onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(notification),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Theme.of(context).colorScheme.surface
              : AppColors.primary.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead
                ? Theme.of(context).colorScheme.outline.withOpacity(0.08)
                : AppColors.primary.withOpacity(0.15),
          ),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _color(notification.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon(notification.type), color: _color(notification.type), size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!notification.isRead) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ]),
              const SizedBox(height: 3),
              Text(
                notification.message,
                style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                _formatTime(notification.createdAt),
                style: TextStyle(color: AppColors.textHint.withOpacity(0.6), fontSize: 10),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  IconData _icon(String type) {
    switch (type) {
      case 'booking':
        return Icons.calendar_today;
      case 'chat':
        return Icons.chat_outlined;
      case 'payment':
        return Icons.payment;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _color(String type) {
    switch (type) {
      case 'booking':
        return AppColors.primary;
      case 'chat':
        return AppColors.info;
      case 'payment':
        return AppColors.success;
      default:
        return AppColors.textHint;
    }
  }

  String _formatTime(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 7) return '${d.inDays}d ago';
    return DateFormat('MMM d').format(t);
  }
}

// ==================== Error View ====================
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          CustomButton(label: 'Retry', icon: Icons.refresh, onPressed: onRetry),
        ]),
      ),
    );
  }
}

// ==================== Shimmer ====================
class _Shimmer extends StatelessWidget {
  const _Shimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder: (_, i) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}