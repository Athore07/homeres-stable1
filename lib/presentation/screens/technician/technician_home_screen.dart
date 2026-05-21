// lib/presentation/screens/technician/technician_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/technician/job_requests_provider.dart';
import '../../providers/technician/schedule_provider.dart';
import '../../providers/technician/earnings_provider.dart';
import '../../widgets/drawer/app_drawer.dart';
import '../../../routing/route_names.dart';

class TechnicianHomeScreen extends ConsumerStatefulWidget {
  const TechnicianHomeScreen({super.key});

  @override
  ConsumerState<TechnicianHomeScreen> createState() => _TechnicianHomeScreenState();
}

class _TechnicianHomeScreenState extends ConsumerState<TechnicianHomeScreen> {
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    _startListeners();
  }

  void _startListeners() {
    final user = ref.read(authProvider).user;
    if (user == null) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jobRequestsProvider.notifier).startListening(user.id);
      ref.read(scheduleProvider.notifier).startListening(user.id);
      ref.read(earningsProvider.notifier).startListening(user.id);
    });
  }

  @override
  void dispose() {
    ref.read(jobRequestsProvider.notifier).stopListening();
    ref.read(scheduleProvider.notifier).stopListening();
    ref.read(earningsProvider.notifier).stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final jobState = ref.watch(jobRequestsProvider);
    final earningsState = ref.watch(earningsProvider);
    final scheduleState = ref.watch(scheduleProvider);

    // Calculate stats
    final todayJobs = scheduleState.todayJobs.length;
    final totalEarnings = earningsState.filteredTotal;
    final rating = 4.8; // This would come from technician profile

    return Scaffold(
      drawer: const AppDrawer(),
      body: CustomScrollView(slivers: [
        SliverAppBar(
          floating: true, snap: true,
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Welcome back,', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
            Text(user?.name ?? 'Technician', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ]),
          actions: [
            IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => context.push(RouteNames.notifications)),
            const SizedBox(width: 8),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Availability Toggle
              _AvailabilityToggle(
                isAvailable: _isAvailable,
                onChanged: (v) => setState(() => _isAvailable = v),
              ),
              const SizedBox(height: 24),

              // Stats Row
              _StatsRow(
                todayJobs: todayJobs,
                earnings: totalEarnings,
                rating: rating,
              ),
              const SizedBox(height: 24),

              // Pending Job Requests
              Text('Pending Job Requests', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (jobState.isLoading && jobState.requests.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (jobState.requests.isEmpty)
                _EmptyCard(icon: Icons.inbox_outlined, message: 'No pending requests')
              else
                ...jobState.requests.take(3).map((r) => _JobRequestCard(
                  request: r,
                  onAccept: (id) {
                    ref.read(jobRequestsProvider.notifier).acceptRequest(id);
                    context.showSnackBar('Request accepted');
                  },
                  onDecline: (id) {
                    ref.read(jobRequestsProvider.notifier).declineRequest(id);
                    context.showSnackBar('Request declined');
                  },
                )),

              const SizedBox(height: 24),

              // Today's Schedule
              Text('Today\'s Schedule', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (scheduleState.todayJobs.isEmpty)
                _EmptyCard(icon: Icons.calendar_today, message: 'No appointments today')
              else
                ...scheduleState.todayJobs.take(3).map((j) => _ScheduleCard(job: j)),
            ]),
          ),
        ),
      ]),
    );
  }
}

// Availability Toggle
class _AvailabilityToggle extends StatelessWidget {
  final bool isAvailable;
  final ValueChanged<bool> onChanged;
  const _AvailabilityToggle({required this.isAvailable, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isAvailable ? AppColors.gradientPrimary : LinearGradient(colors: [Colors.grey[400]!, Colors.grey[600]!]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Icon(isAvailable ? Icons.check_circle : Icons.cancel, color: Colors.white, size: 32),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isAvailable ? 'Available for Jobs' : 'Not Available', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(isAvailable ? 'You are visible to customers' : 'You are not accepting new jobs', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
        ])),
        Switch(value: isAvailable, onChanged: onChanged, activeColor: Colors.white, activeTrackColor: Colors.white.withOpacity(0.3)),
      ]),
    ).animate().fadeIn(duration: 400.ms);
  }
}

// Stats Row
class _StatsRow extends StatelessWidget {
  final int todayJobs;
  final double earnings;
  final double rating;
  const _StatsRow({required this.todayJobs, required this.earnings, required this.rating});

  String _formatCurrency(double amount) {
    if (amount >= 1000) return '\$${(amount / 1000).toStringAsFixed(1)}K';
    return '\$${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: _StatCard(icon: Icons.work, label: 'Today Jobs', value: '$todayJobs', color: AppColors.primary)),
      const SizedBox(width: 12),
      Expanded(child: _StatCard(icon: Icons.account_balance_wallet, label: 'Earnings', value: _formatCurrency(earnings), color: AppColors.success)),
      const SizedBox(width: 12),
      Expanded(child: _StatCard(icon: Icons.star, label: 'Rating', value: rating.toStringAsFixed(1), color: AppColors.accent)),
    ]).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color, fontSize: 18)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
      ]),
    );
  }
}

// Empty Card
class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Icon(icon, size: 48, color: Colors.grey[300]),
        const SizedBox(height: 12),
        Text(message, style: TextStyle(color: Colors.grey[500])),
      ]),
    );
  }
}

// Job Request Card
class _JobRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final Function(String) onAccept;
  final Function(String) onDecline;
  const _JobRequestCard({required this.request, required this.onAccept, required this.onDecline});

  @override
  Widget build(BuildContext context) {
    final isEmergency = request['urgency'] == 'Emergency';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isEmergency ? AppColors.error.withOpacity(0.3) : Colors.grey.withOpacity(0.1), width: isEmergency ? 2 : 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 22, backgroundColor: AppColors.primary.withOpacity(0.1), child: Text((request['customer'] as String? ?? '?')[0].toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(request['customer'] as String? ?? 'Customer', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text(request['service'] as String? ?? '', style: Theme.of(context).textTheme.bodySmall),
            Text(request['time'] as String? ?? '', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
          ])),
          if (isEmergency)
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Text('EMERGENCY', style: TextStyle(color: AppColors.error, fontSize: 9, fontWeight: FontWeight.bold))),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Icon(Icons.attach_money, size: 14, color: Colors.grey[400]), const SizedBox(width: 4),
          Text('\$${(request['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const Spacer(),
          _ActionBtn(icon: Icons.close, color: AppColors.error, onTap: () => onDecline(request['id'] as String)),
          const SizedBox(width: 8),
          _ActionBtn(icon: Icons.check, color: AppColors.success, onTap: () => onAccept(request['id'] as String)),
        ]),
      ]),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 18)),
    );
  }
}

// Schedule Card
class _ScheduleCard extends StatelessWidget {
  final Map<String, dynamic> job;
  const _ScheduleCard({required this.job});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.access_time, color: AppColors.primary, size: 14)),
          const SizedBox(width: 8),
          Text(job['time'] as String? ?? '', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text((job['status'] as String? ?? '').toUpperCase(), style: const TextStyle(color: AppColors.success, fontSize: 9, fontWeight: FontWeight.bold))),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Icon(Icons.person, size: 14, color: Colors.grey[400]), const SizedBox(width: 4),
          Text(job['customer'] as String? ?? '', style: const TextStyle(fontSize: 12)),
        ]),
        const SizedBox(height: 4),
        Row(children: [
          Icon(Icons.build, size: 14, color: Colors.grey[400]), const SizedBox(width: 4),
          Text(job['service'] as String? ?? '', style: const TextStyle(fontSize: 12)),
        ]),
      ]),
    ).animate().fadeIn(duration: 400.ms, delay: 500.ms);
  }
}