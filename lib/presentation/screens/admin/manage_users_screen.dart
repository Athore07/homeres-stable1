// lib/presentation/screens/admin/manage_users_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/admin/users_provider.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/chip_selector.dart';

class ManageUsersScreen extends ConsumerWidget {
  const ManageUsersScreen({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(usersProvider);
    final notifier = ref.read(usersProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: notifier.loadUsers)],
      ),
      body: state.isLoading
          ? const _Shimmer()
          : state.error != null
              ? _ErrorView(error: state.error!, onRetry: notifier.loadUsers)
              : Column(children: [
                  _StatsBar(total: state.totalUsers, active: state.activeUsers, suspended: state.suspendedUsers),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CustomTextField(
                      controller: TextEditingController()..addListener(() => notifier.setSearch(state.searchQuery)),
                      label: 'Search',
                      hint: 'Search by name or email...',
                      prefixIcon: Icons.search,
                      onChanged: notifier.setSearch,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _RoleFilter(selected: state.selectedRole, onSelected: notifier.setRole),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('${state.filteredUsers.length} users found', style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                  ),
                  Expanded(
                    child: state.filteredUsers.isEmpty
                        ? const EmptyStateWidget(icon: Icons.people_outline, title: 'No Users', message: 'No users match criteria')
                        : RefreshIndicator(
                            onRefresh: notifier.loadUsers,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: state.filteredUsers.length,
                              itemBuilder: (_, i) => _UserCard(
                                user: state.filteredUsers[i],
                                index: i,
                                onTap: (u) => _showDetails(context, u),
                                onSuspend: (id) => _confirmSuspend(context, notifier, id, state.filteredUsers[i]['name']),
                                onActivate: (id) => notifier.activateUser(id),
                                onChangeRole: (id, role) => _confirmRoleChange(context, notifier, id, role, state.filteredUsers[i]['name']),
                                onDelete: (id, name) => _confirmDelete(context, notifier, id, name),
                              ),
                            ),
                          ),
                  ),
                ]),
    );
  }

  void _confirmSuspend(BuildContext context, UsersNotifier notifier, String id, String name) {
    ConfirmationDialog.show(context, title: 'Suspend User', message: 'Suspend "$name"?', confirmLabel: 'Suspend', confirmColor: AppColors.warning, icon: Icons.block, onConfirm: () => notifier.suspendUser(id));
  }

  void _confirmRoleChange(BuildContext context, UsersNotifier notifier, String id, String role, String name) {
    final newRole = role == 'homeowner' ? 'Technician' : 'Homeowner';
    ConfirmationDialog.show(context, title: 'Change Role', message: 'Change "$name" to $newRole?', confirmLabel: 'Change', icon: Icons.swap_horiz, onConfirm: () => notifier.changeRole(id, role));
  }

  void _confirmDelete(BuildContext context, UsersNotifier notifier, String id, String name) {
    ConfirmationDialog.show(context, title: 'Delete User', message: 'Delete "$name"?', confirmLabel: 'Delete', confirmColor: AppColors.error, icon: Icons.delete_forever, isDestructive: true, onConfirm: () => notifier.deleteUser(id));
  }

  void _showDetails(BuildContext context, Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (_, scroll) => SingleChildScrollView(
          controller: scroll,
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Row(children: [
              CircleAvatar(radius: 30, backgroundColor: AppColors.primary.withOpacity(0.1), child: Text((user['name'] as String)[0].toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary))),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user['name'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(user['email'] ?? '', style: const TextStyle(color: AppColors.textHint)),
              ])),
            ]),
            const Divider(height: 32),
            _detailRow('User ID', user['id'] ?? ''),
            _detailRow('Phone', user['phone'] ?? 'N/A'),
            _detailRow('Role', (user['role'] as String).toUpperCase()),
            _detailRow('Status', (user['status'] as String).toUpperCase()),
            _detailRow('Verified', user['isVerified'] == true ? 'Yes' : 'No'),
            _detailRow('Bookings', '${user['bookings']}'),
            _detailRow('Joined', DateFormat('MMM d, yyyy').format(user['createdAt'] as DateTime)),
            if (user['lastLogin'] != null) _detailRow('Last Login', DateFormat('MMM d, yyyy - hh:mm a').format(user['lastLogin'] as DateTime)),
          ]),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 13)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
    ]));
  }
}

// Stats Bar
class _StatsBar extends StatelessWidget {
  final int total, active, suspended;
  const _StatsBar({required this.total, required this.active, required this.suspended});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _stat(context, '$total', 'Total'),
        Container(width: 1, height: 30, color: AppColors.divider),
        _stat(context, '$active', 'Active'),
        Container(width: 1, height: 30, color: AppColors.divider),
        _stat(context, '$suspended', 'Suspended'),
      ]),
    );
  }

  Widget _stat(BuildContext context, String value, String label) {
    return Column(children: [
      Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textHint)),
    ]);
  }
}

// Role Filter
class _RoleFilter extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  const _RoleFilter({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ChipSelector<String>(items: const ['All', 'Homeowner', 'Technician', 'Admin'], selectedItem: selected, labelBuilder: (r) => r, onSelected: onSelected),
      ),
    );
  }
}

// User Card
class _UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final int index;
  final Function(Map<String, dynamic>) onTap;
  final Function(String) onSuspend;
  final Function(String) onActivate;
  final Function(String, String) onChangeRole;
  final Function(String, String) onDelete;

  const _UserCard({required this.user, required this.index, required this.onTap, required this.onSuspend, required this.onActivate, required this.onChangeRole, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isSuspended = user['status'] == 'suspended';
    final isAdmin = user['role'] == 'admin';

    return Dismissible(
      key: Key(user['id'] ?? '$index'),
      direction: DismissDirection.endToStart,
      background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.delete, color: Colors.white)),
      confirmDismiss: (_) async { onDelete(user['id'], user['name']); return false; },
      child: GestureDetector(
        onTap: () => onTap(user),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(radius: 24, backgroundColor: AppColors.primary.withOpacity(0.1), child: Text((user['name'] as String)[0].toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(user['name'] ?? '', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                  _StatusBadge(status: user['status']),
                ]),
                Text(user['email'] ?? '', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textHint), overflow: TextOverflow.ellipsis),
              ])),
            ]),
            const Divider(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _chip(Icons.badge, 'Role', (user['role'] as String).toUpperCase()),
              _chip(Icons.work, 'Bookings', '${user['bookings']}'),
              _chip(Icons.calendar_today, 'Joined', DateFormat('MMM d').format(user['createdAt'] as DateTime)),
            ]),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              if (!isAdmin) ...[TextButton.icon(onPressed: () => onChangeRole(user['id'], user['role']), icon: const Icon(Icons.swap_horiz, size: 16), label: const Text('Role', style: TextStyle(fontSize: 12))), const SizedBox(width: 4)],
              TextButton.icon(
                onPressed: () => isSuspended ? onActivate(user['id']) : onSuspend(user['id']),
                icon: Icon(isSuspended ? Icons.check_circle : Icons.block, size: 16, color: isSuspended ? AppColors.success : AppColors.warning),
                label: Text(isSuspended ? 'Activate' : 'Suspend', style: TextStyle(fontSize: 12, color: isSuspended ? AppColors.success : AppColors.warning)),
              ),
            ]),
          ]),
        ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: index * 80)).slideX(begin: 20),
      ),
    );
  }

  Widget _chip(IconData icon, String label, String value) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: AppColors.textHint),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
      Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 9)),
    ]);
  }
}

// Status Badge
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'active' => AppColors.success,
      'suspended' => AppColors.error,
      'pending' => AppColors.warning,
      _ => AppColors.textHint,
    };
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)));
  }
}

// Error View
class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.error_outline, size: 48, color: AppColors.error.withOpacity(0.5)),
      const SizedBox(height: 16), Text(error, textAlign: TextAlign.center),
      const SizedBox(height: 16), CustomButton(label: 'Retry', icon: Icons.refresh, onPressed: onRetry),
    ])));
  }
}

// Shimmer
class _Shimmer extends StatelessWidget {
  const _Shimmer();
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!, child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: 6, itemBuilder: (_, i) => Container(margin: const EdgeInsets.only(bottom: 12), height: 140, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)))));
  }
}