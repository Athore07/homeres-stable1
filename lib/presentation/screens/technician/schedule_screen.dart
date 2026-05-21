// lib/presentation/screens/technician/schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/booking.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/technician/schedule_provider.dart';
import '../../widgets/booking/status_badge.dart';
import '../../widgets/common/empty_state_widget.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user != null) {
        ref.read(scheduleProvider.notifier).startListening(user.id);
      }
    });
  }

  @override
  void dispose() {
    ref.read(scheduleProvider.notifier).stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scheduleProvider);
    final notifier = ref.read(scheduleProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule', style: TextStyle(fontWeight: FontWeight.bold))),
      body: state.isLoading && state.scheduleData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text("An error occurred while fetching schedule. Please make sure you setup profile and try again.", style: const TextStyle(color: AppColors.error)))
              : Column(children: [
                  // Date Selector
                  Container(
                    height: 90, padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 14,
                      itemBuilder: (_, i) {
                        final date = DateTime.now().add(Duration(days: i));
                        final key = DateFormat('yyyy-MM-dd').format(date);
                        final isSelected = key == state.dateKey;

                        return GestureDetector(
                          onTap: () => notifier.selectDate(date),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 62, margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.15)),
                            ),
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text(DateFormat('EEE').format(date), style: TextStyle(color: isSelected ? Colors.white : AppColors.textHint, fontSize: 11, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text(DateFormat('d').format(date), style: TextStyle(color: isSelected ? Colors.white : null, fontSize: 18, fontWeight: FontWeight.bold)),
                              if (state.hasJobs(key)) Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
                            ]),
                          ),
                        );
                      },
                    ),
                  ).animate().fadeIn(duration: 400.ms),

                  // Selected Date Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(children: [
                      Text(DateFormat('EEEE, MMMM d').format(state.selectedDate), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text('${state.todayJobs.length} jobs', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ]),
                  ),

                  // Jobs List
                  Expanded(
                    child: state.todayJobs.isEmpty
                        ? const EmptyStateWidget(icon: Icons.event_busy, title: 'No Jobs', message: 'No jobs scheduled for this day')
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: state.todayJobs.length,
                            itemBuilder: (_, i) => _JobCard(job: state.todayJobs[i], index: i),
                          ),
                  ),
                ]),
    );
  }
}

// Job Card
class _JobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final int index;
  const _JobCard({required this.job, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.access_time_rounded, color: AppColors.primary, size: 14)),
            const SizedBox(width: 8),
            Text(job['time'] as String, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ]),
          StatusBadge(status: job['status'] as BookingStatus),
        ]),
        const Divider(height: 18),
        _InfoRow(icon: Icons.person_rounded, text: job['customer'] as String),
        const SizedBox(height: 5),
        _InfoRow(icon: Icons.build_rounded, text: job['service'] as String),
        const SizedBox(height: 5),
        _InfoRow(icon: Icons.location_on_rounded, text: job['address'] as String),
      ]),
    ).animate().fadeIn(duration: 350.ms, delay: Duration(milliseconds: index * 60)).slideX(begin: 12);
  }
}

// Info Row
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 14, color: Colors.grey[400]),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
    ]);
  }
}