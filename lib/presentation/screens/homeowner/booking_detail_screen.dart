// lib/presentation/screens/homeowner/booking_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/booking.dart';
import '../../providers/homeowner/booking_detail_provider.dart';
import '../../widgets/booking/status_badge.dart';
import '../../../routing/route_names.dart';

class BookingDetailScreen extends ConsumerWidget {
  const BookingDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingDetailProvider);
    final notifier = ref.read(bookingDetailProvider.notifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingId = GoRouterState.of(context).extra as String?;
      if (bookingId != null) notifier.loadBooking(bookingId);
    });

    if (state.isLoading) return Scaffold(appBar: AppBar(title: const Text('Booking Details')), body: const Center(child: CircularProgressIndicator()));
    if (state.error != null) return Scaffold(appBar: AppBar(title: const Text('Booking Details')), body: Center(child: Text(state.error!)));
    if (state.booking == null) return Scaffold(appBar: AppBar(title: const Text('Booking Details')), body: const Center(child: Text('Booking not found')));

    final b = state.booking!;
    final t = state.technician;
    final status = b['status'] as BookingStatus;

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details', style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _StatusBanner(status: status, onTrack: () => context.push(RouteNames.tracking)),
        const SizedBox(height: 24),
        _InfoSection(title: 'Service', items: [{'l': 'Service', 'v': b['service']}, {'l': 'Description', 'v': b['description']?.isNotEmpty == true ? b['description'] : 'N/A'}, {'l': 'Date', 'v': DateFormat('MMM dd, yyyy - hh:mm a').format(b['date'] as DateTime)}]),
        if (t != null) ...[const SizedBox(height: 16), _InfoSection(title: 'Technician', items: [{'l': 'Name', 'v': t['name']}, {'l': 'Specialty', 'v': t['specialty']}, {'l': 'Rating', 'v': '${(t['rating'] as double).toStringAsFixed(1)} ⭐'}, {'l': 'Experience', 'v': '${t['experience']} years'}])],
        const SizedBox(height: 16),
        _InfoSection(title: 'Location', items: [{'l': 'Address', 'v': b['address']}]),
        const SizedBox(height: 16),
        _InfoSection(title: 'Payment', items: [{'l': 'Total', 'v': '\$${(b['totalPrice'] as double).toStringAsFixed(2)}'}, {'l': 'Status', 'v': status.name.toUpperCase()}]),
        if (status == BookingStatus.pending) ...[const SizedBox(height: 24), _CancelButton(onCancel: () async { await notifier.cancelBooking(); if (context.mounted) context.pop(); })]
      ])),
    );
  }
}

// Status Banner
class _StatusBanner extends StatelessWidget {
  final BookingStatus status;
  final VoidCallback? onTrack;
  const _StatusBanner({required this.status, this.onTrack});

  String _msg(BookingStatus s) => switch (s) { BookingStatus.pending => 'Waiting for confirmation', BookingStatus.accepted => 'Technician accepted', BookingStatus.inProgress => 'Work in progress', BookingStatus.completed => 'Service completed', BookingStatus.cancelled => 'Booking cancelled' };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: AppColors.gradientPrimary, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        StatusBadge(status: status, fontSize: 14),
        const SizedBox(height: 12),
        Text(_msg(status), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        if (status == BookingStatus.inProgress && onTrack != null) ...[const SizedBox(height: 12), TextButton.icon(onPressed: onTrack, icon: const Icon(Icons.location_on, color: Colors.white), label: const Text('Track', style: TextStyle(color: Colors.white)), style: TextButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2)))],
      ]),
    ).animate().fadeIn(duration: 400.ms);
  }
}

// Info Section
class _InfoSection extends StatelessWidget {
  final String title;
  final List<Map<String, String>> items;
  const _InfoSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
        const Divider(),
        ...items.map((i) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(i['l']!, style: TextStyle(color: Colors.grey[600], fontSize: 13)), Flexible(child: Text(i['v']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), textAlign: TextAlign.right))]))),
      ]),
    ).animate().fadeIn(duration: 400.ms);
  }
}

// Cancel Button
class _CancelButton extends StatelessWidget {
  final VoidCallback onCancel;
  const _CancelButton({required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: onCancel, icon: const Icon(Icons.close, color: AppColors.error), label: const Text('Cancel Booking', style: TextStyle(color: AppColors.error)), style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error), padding: const EdgeInsets.symmetric(vertical: 14))));
  }
}