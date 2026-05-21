// lib/presentation/widgets/booking/booking_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/booking.dart';
import 'status_badge.dart';

class BookingCard extends StatelessWidget {
  final BookingEntity booking;
  final VoidCallback? onTap;
  final VoidCallback? onTrack;
  final VoidCallback? onCancel;
  final VoidCallback? onRate;

  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.onTrack,
    this.onCancel,
    this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.serviceName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                StatusBadge(status: booking.status),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              Icons.calendar_today_outlined,
              DateFormat('MMM dd, yyyy').format(booking.scheduledTime),
            ),
            const SizedBox(height: 6),
            _buildInfoRow(
              context,
              Icons.access_time,
              DateFormat('hh:mm a').format(booking.scheduledTime),
            ),
            const SizedBox(height: 6),
            _buildInfoRow(
              context,
              Icons.location_on_outlined,
              booking.address,
            ),
            if (booking.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              _buildInfoRow(
                context,
                Icons.description_outlined,
                booking.description,
              ),
            ],
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${booking.totalPrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    if (booking.status == BookingStatus.inProgress && onTrack != null)
                      TextButton.icon(
                        onPressed: onTrack,
                        icon: const Icon(Icons.location_on, size: 18),
                        label: const Text('Track'),
                      ),
                    if (booking.status == BookingStatus.pending && onCancel != null)
                      TextButton.icon(
                        onPressed: onCancel,
                        icon: const Icon(Icons.close, size: 18, color: AppColors.error),
                        label: const Text('Cancel', style: TextStyle(color: AppColors.error)),
                      ),
                    if (booking.status == BookingStatus.completed && onRate != null)
                      TextButton.icon(
                        onPressed: onRate,
                        icon: const Icon(Icons.star, size: 18),
                        label: const Text('Rate'),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}