// lib/presentation/screens/admin/manage_technicians_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/technician.dart';
import '../../providers/technician/technician_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/chip_selector.dart';

class ManageTechniciansScreen extends ConsumerWidget {
  const ManageTechniciansScreen({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(technicianProvider);
    final notifier = ref.read(technicianProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Technicians', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: notifier.loadTechnicians)],
      ),
      body: state.isLoading
          ? const _Shimmer()
          : state.error != null
              ? _ErrorView(error: state.error!, onRetry: notifier.loadTechnicians)
              : Column(children: [
                  if (state.pendingCount > 0)
                    _PendingAlert(count: state.pendingCount, onTap: () => notifier.setFilter('Pending')),
                  _FilterRow(selected: state.selectedFilter, onSelected: notifier.setFilter, total: state.totalCount),
                  const SizedBox(height: 12),
                  Expanded(
                    child: state.technicians.isEmpty
                        ? const EmptyStateWidget(icon: Icons.engineering, title: 'No Technicians', message: 'No technicians match filter')
                        : RefreshIndicator(
                            onRefresh: notifier.loadTechnicians,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: state.technicians.length,
                              itemBuilder: (_, i) => _TechCard(
                                tech: state.technicians[i],
                                index: i,
                                onVerify: (id, name) => notifier.verifyTechnician(id),
                                onReject: (id, name) => notifier.rejectTechnician(id),
                                onDelete: (id, name) => _delete(context, notifier, id, name),
                              ),
                            ),
                          ),
                  ),
                ]),
    );
  }

  void _delete(BuildContext context, TechnicianNotifier notifier, String id, String name) {
    ConfirmationDialog.show(
      context,
      title: 'Delete Technician',
      message: 'Delete "$name"?',
      confirmLabel: 'Delete',
      confirmColor: AppColors.error,
      icon: Icons.delete_forever,
      isDestructive: true,
      onConfirm: () => notifier.deleteTechnician(id),
    );
  }
}

// Pending Alert Widget
class _PendingAlert extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _PendingAlert({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.warning.withOpacity(0.3)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: Text('$count', style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Pending Verification', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.warning, fontWeight: FontWeight.bold)),
              Text('Technicians waiting for approval', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.warning.withOpacity(0.7))),
            ]),
          ),
          const Icon(Icons.arrow_forward_ios, color: AppColors.warning, size: 16),
        ]),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

// Filter Row Widget
class _FilterRow extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  final int total;
  const _FilterRow({required this.selected, required this.onSelected, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ChipSelector<String>(
          items: const ['All', 'Verified', 'Pending', 'Rejected'],
          selectedItem: selected,
          labelBuilder: (f) => f == 'All' ? 'All ($total)' : f,
          onSelected: onSelected,
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }
}

// Technician Card Widget
class _TechCard extends StatelessWidget {
  final TechnicianEntity tech;
  final int index;
  final Function(String, String) onVerify;
  final Function(String, String) onReject;
  final Function(String, String) onDelete;

  const _TechCard({
    required this.tech,
    required this.index,
    required this.onVerify,
    required this.onReject,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = tech.isPending;

    return Dismissible(
      key: Key(tech.id),
      direction: DismissDirection.endToStart,
      background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.delete, color: Colors.white)),
      confirmDismiss: (_) async { onDelete(tech.id, tech.name); return false; },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isPending ? AppColors.warning.withOpacity(0.3) : Theme.of(context).colorScheme.outline.withOpacity(0.1), width: isPending ? 2 : 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(radius: 28, backgroundColor: AppColors.primary.withOpacity(0.1), child: Text(tech.name[0].toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 22))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(tech.name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                _StatusBadge(status: tech.verificationStatus),
              ]),
              Text(tech.specialty, style: Theme.of(context).textTheme.bodySmall),
              Text(tech.email, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textHint, fontSize: 11)),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.star, color: AppColors.accent, size: 14), const SizedBox(width: 4),
                Text(tech.rating.toStringAsFixed(1), style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 12)),
                const SizedBox(width: 12),
                Icon(Icons.work, size: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)), const SizedBox(width: 4),
                Text('${tech.totalJobs} jobs', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12)),
                const SizedBox(width: 12),
                Container(width: 6, height: 6, decoration: BoxDecoration(color: tech.isAvailable ? AppColors.success : Colors.grey, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text(tech.isAvailable ? 'Online' : 'Offline', style: TextStyle(fontSize: 11, color: tech.isAvailable ? AppColors.success : AppColors.textHint)),
              ]),
            ])),
          ]),
          if (tech.skills.isNotEmpty) ...[const SizedBox(height: 12), _Tags(items: tech.skills, color: AppColors.primary)],
          if (tech.certifications.isNotEmpty) ...[const SizedBox(height: 8), _Tags(items: tech.certifications, color: AppColors.success)],
          if (isPending) ...[const SizedBox(height: 12), _ActionButtons(onReject: () => onReject(tech.id, tech.name), onVerify: () => onVerify(tech.id, tech.name))],
          if (tech.isVerified) ...[const SizedBox(height: 12), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('\$${tech.hourlyRate.toStringAsFixed(0)}/hr', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
            Text('${tech.experience} yrs exp', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
          ])],
        ]),
      ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: index * 80)).slideX(begin: index % 2 == 0 ? -20 : 20),
    );
  }
}

// Status Badge
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = switch (status) {
      'verified' => (AppColors.success, Icons.verified, 'VERIFIED'),
      'pending' => (AppColors.warning, Icons.pending, 'PENDING'),
      'rejected' => (AppColors.error, Icons.cancel, 'REJECTED'),
      _ => (AppColors.textHint, Icons.help, 'UNKNOWN'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: config.$1.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(config.$2, color: config.$1, size: 12),
        const SizedBox(width: 4),
        Text(config.$3, style: TextStyle(color: config.$1, fontSize: 9, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

// Skills/Certifications Tags
class _Tags extends StatelessWidget {
  final List<String> items;
  final Color color;
  const _Tags({required this.items, required this.color});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4, runSpacing: 4,
      children: items.map((item) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
        child: Text(item, style: TextStyle(fontSize: 10, color: color)),
      )).toList(),
    );
  }
}

// Action Buttons (Verify/Reject)
class _ActionButtons extends StatelessWidget {
  final VoidCallback onReject;
  final VoidCallback onVerify;
  const _ActionButtons({required this.onReject, required this.onVerify});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      OutlinedButton.icon(
        onPressed: onReject,
        icon: const Icon(Icons.close, size: 16),
        label: const Text('Reject'),
        style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), minimumSize: Size.zero, textStyle: const TextStyle(fontSize: 12)),
      ),
      const SizedBox(width: 8),
      ElevatedButton.icon(
        onPressed: onVerify,
        icon: const Icon(Icons.check, size: 16),
        label: const Text('Verify'),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), minimumSize: Size.zero, textStyle: const TextStyle(fontSize: 12)),
      ),
    ]);
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
      child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.error_outline, size: 48, color: AppColors.error.withOpacity(0.5)),
        const SizedBox(height: 16),
        Text(error, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        CustomButton(label: 'Retry', icon: Icons.refresh, onPressed: onRetry),
      ])),
    );
  }
}

// Shimmer
class _Shimmer extends StatelessWidget {
  const _Shimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!,
      child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: 5, itemBuilder: (_, i) => Container(margin: const EdgeInsets.only(bottom: 12), height: 160, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)))),
    );
  }
}