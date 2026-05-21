// lib/presentation/screens/admin/manage_services_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../providers/admin/services_provider.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/common/empty_state_widget.dart';

class ManageServicesScreen extends ConsumerWidget {
  const ManageServicesScreen({super.key});

  static const _icons = {
    'electrical repair': Icons.electrical_services,
    'plumbing': Icons.plumbing,
    'appliance repair': Icons.kitchen,
    'ac service': Icons.ac_unit,
    'carpentry': Icons.carpenter,
    'painting': Icons.format_paint,
  };

  IconData _getIcon(String name) => _icons[name.toLowerCase()] ?? Icons.build;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(servicesProvider);
    final notifier = ref.read(servicesProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Services', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: notifier.loadServices, tooltip: 'Refresh'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDialog(context, notifier, null),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Service'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: state.isLoading
          ? const _Shimmer()
          : state.error != null
              ? _ErrorView(error: state.error!, onRetry: notifier.loadServices)
              : state.services.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.miscellaneous_services_rounded,
                      title: 'No Services',
                      message: 'Tap + to add your first service',
                    )
                  : RefreshIndicator(
                      onRefresh: notifier.loadServices,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: state.services.length,
                        itemBuilder: (_, i) => _ServiceCard(
                          service: state.services[i],
                          index: i,
                          onEdit: (s) => _showDialog(context, notifier, s),
                          onToggle: (id, active) => notifier.toggleStatus(id, active),
                          onDelete: (id, name) => _delete(context, notifier, id, name),
                          getIcon: _getIcon,
                        ),
                      ),
                    ),
    );
  }

  void _showDialog(BuildContext context, ServicesNotifier notifier, Map<String, dynamic>? service) {
    final nameCtrl = TextEditingController(text: service?['name'] ?? '');
    final catCtrl = TextEditingController(text: service?['category'] ?? '');
    final descCtrl = TextEditingController(text: service?['description'] ?? '');
    final priceCtrl = TextEditingController(text: service?['basePrice']?.toString() ?? '');
    final isEdit = service != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(isEdit ? Icons.edit_rounded : Icons.add_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Text(isEdit ? 'Edit Service' : 'New Service', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ]),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CustomTextField(controller: nameCtrl, label: 'Service Name', hint: 'e.g., Electrical Repair', prefixIcon: Icons.build_rounded),
            const SizedBox(height: 14),
            CustomTextField(controller: catCtrl, label: 'Category', hint: 'e.g., Electrical', prefixIcon: Icons.category_rounded),
            const SizedBox(height: 14),
            CustomTextField(controller: descCtrl, label: 'Description', hint: 'Describe the service...', prefixIcon: Icons.description_rounded, maxLines: 2),
            const SizedBox(height: 14),
            CustomTextField(controller: priceCtrl, label: 'Base Price (\$)', hint: 'e.g., 50.00', prefixIcon: Icons.attach_money_rounded, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600))),
          CustomButton(label: isEdit ? 'Update' : 'Add Service', height: 44, onPressed: () async {
            if (nameCtrl.text.trim().isEmpty) { context.showSnackBar('Name is required'); return; }
            final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
            if (price <= 0) { context.showSnackBar('Valid price required'); return; }
            await notifier.saveService(name: nameCtrl.text.trim(), category: catCtrl.text.trim(), description: descCtrl.text.trim(), price: price, serviceId: service?['id']);
            if (ctx.mounted) Navigator.pop(ctx);
          }),
        ],
      ),
    );
  }

  void _delete(BuildContext context, ServicesNotifier notifier, String id, String name) {
    ConfirmationDialog.show(context, title: 'Delete Service', message: 'Delete "$name"? This cannot be undone.', confirmLabel: 'Delete', isDestructive: true, onConfirm: () {
      notifier.deleteService(id);
      context.showSnackBar('$name deleted');
    });
  }
}

// Service Card
class _ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final int index;
  final Function(Map<String, dynamic>) onEdit;
  final Function(String, bool) onToggle;
  final Function(String, String) onDelete;
  final IconData Function(String) getIcon;

  const _ServiceCard({required this.service, required this.index, required this.onEdit, required this.onToggle, required this.onDelete, required this.getIcon});

  @override
  Widget build(BuildContext context) {
    final isActive = service['isActive'] == true;
    final name = service['name'] as String? ?? 'Unknown';
    final description = service['description'] as String? ?? '';
    final category = service['category'] as String? ?? 'N/A';
    final price = (service['basePrice'] as num?)?.toDouble() ?? 0.0;
    final techCount = service['technicianCount'] as int? ?? 0;
    final icon = getIcon(name);

    return Dismissible(
      key: Key(service['id'] ?? '$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(18)),
        child: const Row(mainAxisAlignment: MainAxisAlignment.end, children: [Icon(Icons.delete_rounded, color: Colors.white, size: 24), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))]),
      ),
      confirmDismiss: (_) async { onDelete(service['id'], name); return false; },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isActive ? Colors.grey.withOpacity(0.1) : AppColors.error.withOpacity(0.2)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    _StatusBadge(isActive: isActive),
                  ]),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(description, style: TextStyle(color: Colors.grey[500], fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ]),
              ),
              Switch(value: isActive, onChanged: (v) => onToggle(service['id'], v), activeColor: AppColors.primary),
            ]),
          ),
          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(children: [
              _StatChip(icon: Icons.category_rounded, value: category),
              const SizedBox(width: 16),
              _StatChip(icon: Icons.attach_money_rounded, value: '\$${price.toStringAsFixed(0)}/hr'),
              const SizedBox(width: 16),
              _StatChip(icon: Icons.engineering_rounded, value: '$techCount techs'),
            ]),
          ),
          // Actions
          Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton.icon(onPressed: () => onEdit(service), icon: const Icon(Icons.edit_rounded, size: 16), label: const Text('Edit', style: TextStyle(fontSize: 12)), style: TextButton.styleFrom(foregroundColor: AppColors.primary, visualDensity: VisualDensity.compact)),
              TextButton.icon(onPressed: () => onDelete(service['id'], name), icon: const Icon(Icons.delete_outline_rounded, size: 16), label: const Text('Delete', style: TextStyle(fontSize: 12)), style: TextButton.styleFrom(foregroundColor: AppColors.error, visualDensity: VisualDensity.compact)),
            ]),
          ),
        ]),
      ).animate().fadeIn(duration: 350.ms, delay: Duration(milliseconds: index * 60)).slideX(begin: 16),
    );
  }
}

// Status Badge
class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (isActive ? AppColors.success : AppColors.error).withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(isActive ? 'Active' : 'Inactive', style: TextStyle(color: isActive ? AppColors.success : AppColors.error, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}

// Stat Chip
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  const _StatChip({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: Colors.grey[400]),
      const SizedBox(width: 4),
      Text(value, style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
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
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.error.withOpacity(0.08), shape: BoxShape.circle), child: const Icon(Icons.error_outline_rounded, size: 40, color: AppColors.error)),
        const SizedBox(height: 16),
        Text('Failed to load services', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(error, style: TextStyle(color: Colors.grey[500], fontSize: 12), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        CustomButton(label: 'Retry', icon: Icons.refresh_rounded, onPressed: onRetry),
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
      child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: 4, itemBuilder: (_, i) => Container(margin: const EdgeInsets.only(bottom: 10), height: 150, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)))),
    );
  }
}