// lib/presentation/screens/technician/job_requests_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/technician/job_requests_provider.dart';
import '../../widgets/common/empty_state_widget.dart';

class JobRequestsScreen extends ConsumerStatefulWidget {
  const JobRequestsScreen({super.key});

  @override
  ConsumerState<JobRequestsScreen> createState() => _JobRequestsScreenState();
}

class _JobRequestsScreenState extends ConsumerState<JobRequestsScreen> {
  @override
  void initState() {
    super.initState();
    // Start real-time listener
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user != null) {
        ref.read(jobRequestsProvider.notifier).startListening(user.id);
      }
    });
  }

  @override
  void dispose() {
    // Stop listener when screen closes
    ref.read(jobRequestsProvider.notifier).stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobRequestsProvider);
    final notifier = ref.read(jobRequestsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Requests', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (state.requests.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Text('${state.requests.length} pending', style: const TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: state.isLoading && state.requests.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text("An error occurred while fetching job requests. Please make sure you setup profile and try again.", style: const TextStyle(color: AppColors.error)))
              : state.requests.isEmpty
                  ? const EmptyStateWidget(icon: Icons.work_outline, title: 'No Pending Requests', message: 'New job requests will appear here automatically.')
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.requests.length,
                      itemBuilder: (_, i) => _RequestCard(
                        request: state.requests[i],
                        onAccept: (id) {
                          notifier.acceptRequest(id);
                          context.showSnackBar('Request accepted');
                        },
                        onDecline: (id) {
                          notifier.declineRequest(id);
                          context.showSnackBar('Request declined');
                        },
                      ),
                    ),
    );
  }
}

// Request Card
class _RequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final Function(String) onAccept;
  final Function(String) onDecline;

  const _RequestCard({required this.request, required this.onAccept, required this.onDecline});

  @override
  Widget build(BuildContext context) {
    final isEmergency = request['urgency'] == 'Emergency';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isEmergency ? AppColors.error.withOpacity(0.3) : Colors.grey.withOpacity(0.1), width: isEmergency ? 2 : 1),
        boxShadow: [BoxShadow(color: (isEmergency ? AppColors.error : Colors.black).withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            CircleAvatar(radius: 22, backgroundColor: AppColors.primary.withOpacity(0.08), child: Text((request['customer'] as String)[0].toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16))),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(request['customer'] as String, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text(request['time'] as String, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
            ]),
          ]),
          if (isEmergency)
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.error.withOpacity(0.08), borderRadius: BorderRadius.circular(8)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 14), SizedBox(width: 4), Text('EMERGENCY', style: TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.bold))])),
        ]),
        const SizedBox(height: 14),
        // Details
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
          child: Column(children: [
            _DetailRow(icon: Icons.build_rounded, label: 'Service', value: request['service'] as String),
            const SizedBox(height: 6),
            _DetailRow(icon: Icons.location_on_rounded, label: 'Address', value: request['address'] as String),
            const SizedBox(height: 6),
            _DetailRow(icon: Icons.attach_money_rounded, label: 'Price', value: '\$${(request['price'] as double).toStringAsFixed(2)}'),
          ]),
        ),
        const SizedBox(height: 14),
        // Actions
        Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: () => onDecline(request['id'] as String), icon: const Icon(Icons.close_rounded, size: 18), label: const Text('Decline'), style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))),
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton.icon(onPressed: () => onAccept(request['id'] as String), icon: const Icon(Icons.check_rounded, size: 18), label: const Text('Accept'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))),
        ]),
      ]),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 16);
  }
}

// Detail Row
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 14, color: Colors.grey[400]),
      const SizedBox(width: 8),
      Text('$label: ', style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.w600)),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
    ]);
  }
}