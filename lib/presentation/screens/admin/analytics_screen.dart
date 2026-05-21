// lib/presentation/screens/admin/analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/admin/analytics_provider.dart';
import '../../widgets/common/custom_button.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  String _formatCurrency(double amount) {
    if (amount >= 1000000) return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '\$${(amount / 1000).toStringAsFixed(1)}K';
    return '\$${amount.toStringAsFixed(2)}';
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analyticsProvider);
    final notifier = ref.read(analyticsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: notifier.loadData)],
      ),
      body: state.isLoading
          ? const _Shimmer()
          : state.error != null
              ? _ErrorView(error: state.error!, onRetry: notifier.loadData)
              : RefreshIndicator(
                  onRefresh: notifier.loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _PeriodFilter(selected: state.selectedPeriod, onSelected: notifier.setPeriod),
                      const SizedBox(height: 16),
                      _RevenueCard(revenue: state.totalRevenue, growth: state.revenueGrowth).animate().fadeIn(duration: 400.ms),
                      const SizedBox(height: 16),
                      _StatsRow(bookings: state.totalBookings, users: state.totalUsers, rate: state.completionRate).animate().fadeIn(duration: 400.ms),
                      const SizedBox(height: 24),
                      Text('Booking Trends', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _TrendChart(monthlyBookings: state.monthlyBookings),
                      if (state.topServices.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text('Top Services', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _TopServices(services: state.topServices),
                      ],
                      if (state.topTechnicians.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text('Top Technicians', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _TopTechnicians(technicians: state.topTechnicians, formatCurrency: _formatCurrency),
                      ],
                      const SizedBox(height: 32),
                    ]),
                  ),
                ),
    );
  }
}

// Period Filter Widget
class _PeriodFilter extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  const _PeriodFilter({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['Today', 'This Week', 'This Month', 'This Year'].map((period) {
          final isSelected = selected == period;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(period, style: TextStyle(color: isSelected ? Colors.white : null, fontWeight: FontWeight.w600, fontSize: 12)),
              selected: isSelected,
              onSelected: (_) => onSelected(period),
              selectedColor: AppColors.primary,
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Revenue Card Widget
class _RevenueCard extends StatelessWidget {
  final double revenue;
  final double growth;
  const _RevenueCard({required this.revenue, required this.growth});

  String _format(double amount) {
    if (amount >= 1000000) return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '\$${(amount / 1000).toStringAsFixed(1)}K';
    return '\$${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(gradient: AppColors.gradientPrimary, borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Total Revenue', style: TextStyle(color: Colors.white70, fontSize: 14)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(growth >= 0 ? Icons.arrow_upward : Icons.arrow_downward, color: Colors.white, size: 14),
              const SizedBox(width: 2),
              Text('${growth.abs().toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        Text(_format(revenue), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(DateFormat('MMMM yyyy').format(DateTime.now()), style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ]),
    );
  }
}

// Stats Row Widget
class _StatsRow extends StatelessWidget {
  final int bookings;
  final int users;
  final double rate;
  const _StatsRow({required this.bookings, required this.users, required this.rate});

  String _format(int number) {
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    final stats = [
      {'label': 'Bookings', 'value': _format(bookings), 'icon': Icons.work, 'color': AppColors.primary},
      {'label': 'Users', 'value': _format(users), 'icon': Icons.people, 'color': AppColors.success},
      {'label': 'Completion', 'value': '${rate.toStringAsFixed(0)}%', 'icon': Icons.check_circle, 'color': AppColors.info},
    ];

    return Row(
      children: stats.map((s) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(s['icon'] as IconData, color: s['color'] as Color, size: 24),
            const SizedBox(height: 8),
            FittedBox(child: Text(s['value'] as String, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 20))),
            Text(s['label'] as String, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textHint, fontSize: 11)),
          ]),
        ),
      )).toList(),
    );
  }
}

// Trend Chart Widget
class _TrendChart extends StatelessWidget {
  final Map<String, int> monthlyBookings;
  const _TrendChart({required this.monthlyBookings});

  @override
  Widget build(BuildContext context) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final currentMonth = DateTime.now().month;
    final orderedData = <int>[];

    for (int i = 11; i >= 0; i--) {
      final idx = (currentMonth - i - 1 + 12) % 12;
      orderedData.add(monthlyBookings[months[idx]] ?? 0);
    }

    final maxValue = orderedData.isEmpty ? 1 : orderedData.reduce((a, b) => a > b ? a : b);
    final chartMax = maxValue > 0 ? maxValue.toDouble() : 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: months.map((m) => Expanded(child: Text(m, style: const TextStyle(fontSize: 9, color: AppColors.textHint), textAlign: TextAlign.center))).toList()),
        const SizedBox(height: 12),
        SizedBox(height: 120, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: orderedData.map((v) {
          final h = maxValue > 0 ? (v / chartMax) * 120 : 0.0;
          return Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 2), child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            Container(height: h, decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.8), AppColors.primary.withOpacity(0.2)], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))),
          ])));
        }).toList())),
      ]),
    );
  }
}

// Top Services Widget
class _TopServices extends StatelessWidget {
  final List<Map<String, dynamic>> services;
  const _TopServices({required this.services});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(children: services.map((s) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Flexible(child: Text(s['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
            Text('${s['bookings']} bookings', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
          ]),
          const SizedBox(height: 4),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: (s['percentage'] as double).clamp(0.0, 1.0), backgroundColor: AppColors.primary.withOpacity(0.1), valueColor: const AlwaysStoppedAnimation(AppColors.primary), minHeight: 6)),
        ]),
      )).toList()),
    );
  }
}

// Top Technicians Widget
class _TopTechnicians extends StatelessWidget {
  final List<Map<String, dynamic>> technicians;
  final String Function(double) formatCurrency;
  const _TopTechnicians({required this.technicians, required this.formatCurrency});

  @override
  Widget build(BuildContext context) {
    return Column(children: technicians.map((t) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        CircleAvatar(radius: 20, backgroundColor: AppColors.primary.withOpacity(0.1), child: Text((t['name'] as String)[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
          Row(children: [
            const Icon(Icons.star, color: AppColors.accent, size: 14), const SizedBox(width: 4),
            Text((t['rating'] as double).toStringAsFixed(1)),
            const SizedBox(width: 12),
            Text('${t['jobs']} jobs', style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
          ]),
        ])),
        Text(formatCurrency(t['revenue'] as double), style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 13)),
      ]),
    )).toList());
  }
}

// Error View
class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(error, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          CustomButton(label: 'Retry', icon: Icons.refresh, onPressed: onRetry),
        ]),
      ),
    );
  }
}

// Shimmer
class _Shimmer extends StatelessWidget {
  const _Shimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: List.generate(4, (_) => Container(margin: const EdgeInsets.only(right: 8), width: 80, height: 32, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))))),
          const SizedBox(height: 16),
          Container(width: double.infinity, height: 140, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
          const SizedBox(height: 16),
          Row(children: List.generate(3, (_) => Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)))))),
          const SizedBox(height: 24),
          Container(width: double.infinity, height: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
        ]),
      ),
    );
  }
}