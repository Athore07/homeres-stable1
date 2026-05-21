// lib/presentation/screens/homeowner/booking_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/booking.dart';
import '../../widgets/booking/status_badge.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/homeowner/booking_history_provider.dart';
import '../../../routing/route_names.dart';

class BookingHistoryScreen extends ConsumerWidget {
  const BookingHistoryScreen({super.key});

  static const _filters = ['All', 'Pending', 'In Progress', 'Completed', 'Cancelled'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingHistoryProvider);
    final notifier = ref.read(bookingHistoryProvider.notifier);
    final user = ref.watch(authProvider).user;

    // Load bookings when user is available
    if (user != null && state.bookings.isEmpty && !state.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => notifier.loadBookings(user.id));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Booking History', style: TextStyle(fontWeight: FontWeight.bold))),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text(state.error!))
              : Column(children: [
                  _FilterRow(filters: _filters, selected: state.selectedFilter, onSelected: notifier.setFilter),
                  Expanded(
                    child: state.filtered.isEmpty
                        ? const EmptyStateWidget(icon: Icons.history, title: 'No Bookings', message: 'Your booking history will appear here.')
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: state.filtered.length,
                            itemBuilder: (_, i) => _BookingCard(booking: state.filtered[i], onTap: (b) => _handleTap(context, b)),
                          ),
                  ),
                ]),
    );
  }

  void _handleTap(BuildContext context, Map<String, dynamic> b) {
    final status = b['status'] as BookingStatus;
    if (status == BookingStatus.inProgress) context.push(RouteNames.tracking);
    if (status == BookingStatus.completed) context.push(RouteNames.review);
    if (status == BookingStatus.pending) context.push(RouteNames.bookingDetail, extra: b['id']);
  }
}

// Filter Row
class _FilterRow extends StatelessWidget {
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;
  const _FilterRow({required this.filters, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48, margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: filters.map((f) {
        final sel = selected == f;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onSelected(f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: sel ? AppColors.primary : Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? AppColors.primary : Colors.grey.withOpacity(0.2))),
              child: Text(f, style: TextStyle(color: sel ? Colors.white : Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600, fontSize: 12)),
            ),
          ),
        );
      }).toList()),
    );
  }
}

// Booking Card
class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final Function(Map<String, dynamic>) onTap;
  const _BookingCard({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final status = booking['status'] as BookingStatus;
    return GestureDetector(
      onTap: () => onTap(booking),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(booking['service'] as String, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            StatusBadge(status: status),
          ]),
          const SizedBox(height: 12),
          _InfoRow(icon: Icons.person_outline, label: 'Technician', value: booking['technician'] as String),
          _InfoRow(icon: Icons.calendar_today_outlined, label: 'Date', value: DateFormat('MMM dd, yyyy').format(booking['date'] as DateTime)),
          _InfoRow(icon: Icons.location_on_outlined, label: 'Address', value: booking['address'] as String),
          const Divider(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('\$${(booking['price'] as double).toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
            if (status == BookingStatus.completed) _Rating(rating: (booking['rating'] as double?) ?? 0),
            if (status == BookingStatus.inProgress) TextButton(onPressed: () => onTap(booking), child: const Text('Track')),
          ]),
        ]),
      ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: 50)).slideX(begin: 20),
    );
  }
}

// Info Row
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}

// Rating
class _Rating extends StatelessWidget {
  final double rating;
  const _Rating({required this.rating});

  @override
  Widget build(BuildContext context) {
    if (rating == 0) return TextButton(onPressed: () {}, child: const Text('Rate'));
    return Row(children: [const Icon(Icons.star, color: Colors.amber, size: 16), const SizedBox(width: 4), Text(rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber))]);
  }
}