// lib/presentation/screens/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/admin/admin_dashboard_provider.dart';
import '../../widgets/common/info_card.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/chip_selector.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/badge_icon.dart';
import '../../../routing/route_names.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  String _formatNumber(num number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toStringAsFixed(0);
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '\$${(amount / 1000).toStringAsFixed(1)}K';
    return '\$${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ FIX: Access auth state correctly
    final authState = ref.watch(authProvider);
    final user = authState.user;
    
    // ✅ FIX: Use generated provider name
    final dashState = ref.watch(dashboardProvider);
    final notifier = ref.read(dashboardProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: dashState.isLoading
          ? const DashboardShimmer()
          : dashState.error != null
              ? _ErrorView(error: dashState.error ?? 'Unknown error', onRetry: notifier.loadData)
              : RefreshIndicator(
                  onRefresh: () => notifier.loadData(),
                  child: CustomScrollView(
                    slivers: [
                      _buildAppBar(context, user, dashState.pendingVerifications, notifier.loadData, isDark),
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverToBoxAdapter(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _buildPeriodFilter(dashState.selectedPeriod, notifier.setPeriod),
                            const SizedBox(height: 16),
                            _buildStatsGrid(context, dashState),
                            const SizedBox(height: 24),
                            _buildQuickActions(context),
                            const SizedBox(height: 24),
                            if (dashState.pendingVerifications > 0) ...[
                              _buildPendingActions(context, dashState.pendingVerifications),
                              const SizedBox(height: 24),
                            ],
                            _buildActiveJobs(context, dashState.activeJobs),
                            const SizedBox(height: 16),
                            _buildSystemStatus(context),
                            const SizedBox(height: 32),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildAppBar(BuildContext context, dynamic user, int pending, VoidCallback onRefresh, bool isDark) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false, pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Column(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Admin Dashboard', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
          Text('Welcome back, ${user?.name ?? 'Admin'}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
        ]),
        background: Container(
          decoration: BoxDecoration(gradient: LinearGradient(colors: isDark ? [const Color(0xFF1E293B), const Color(0xFF0F172A)] : [AppColors.primary, AppColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        ),
      ),
      actions: [
        BadgeIcon(icon: Icons.notifications_outlined, count: pending, iconColor: Colors.white, onTap: () => context.push(RouteNames.notifications)),
        IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: onRefresh, tooltip: 'Refresh'),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildPeriodFilter(String selected, ValueChanged<String> onSelected) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ChipSelector<String>(items: const ['Today', 'This Week', 'This Month', 'This Year'], selectedItem: selected, labelBuilder: (p) => p, onSelected: onSelected),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildStatsGrid(BuildContext context, DashboardState state) {
    return LayoutBuilder(
      builder: (context, constraints) => Wrap(spacing: 8, runSpacing: 8, children: [
        _statCard(constraints, 'Total Users', _formatNumber(state.totalUsers), Icons.people, AppColors.primary),
        _statCard(constraints, 'Technicians', _formatNumber(state.totalTechnicians), Icons.engineering, AppColors.success),
        _statCard(constraints, 'Bookings', _formatNumber(state.totalBookings), Icons.work, AppColors.accent),
        _statCard(constraints, 'Revenue', _formatCurrency(state.totalRevenue), Icons.attach_money, AppColors.info),
      ]),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _statCard(BoxConstraints constraints, String title, String value, IconData icon, Color color) {
    return SizedBox(width: (constraints.maxWidth - 8) / 2, child: InfoCard(title: title, value: value, icon: icon, color: color));
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(title: 'Quick Actions').animate().fadeIn(duration: 400.ms, delay: 200.ms),
      const SizedBox(height: 12),
      LayoutBuilder(
        builder: (context, constraints) => Wrap(spacing: 8, runSpacing: 8, children: [
          _actionBtn(constraints, 'Users', Icons.people, RouteNames.manageUsers, context),
          _actionBtn(constraints, 'Techs', Icons.engineering, RouteNames.manageTechnicians, context),
          _actionBtn(constraints, 'Services', Icons.miscellaneous_services, RouteNames.manageServices, context),
          _actionBtn(constraints, 'Analytics', Icons.analytics, RouteNames.analytics, context),
        ]),
      ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
    ]);
  }

  Widget _actionBtn(BoxConstraints c, String label, IconData icon, String route, BuildContext ctx) {
    return SizedBox(width: (c.maxWidth - 8) / 2, child: CustomButton(label: label, icon: icon, isOutlined: true, height: 48, onPressed: () => ctx.push(route)));
  }

  Widget _buildPendingActions(BuildContext context, int count) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.warning.withOpacity(0.3))),
      child: Row(children: [
        const Icon(Icons.pending_actions, color: AppColors.warning, size: 24), const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$count technicians pending', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: AppColors.warning)),
          const SizedBox(height: 8),
          SizedBox(height: 36, child: ElevatedButton(onPressed: () => context.push(RouteNames.manageTechnicians), style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning, foregroundColor: Colors.white, minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 16)), child: const Text('Review Now', style: TextStyle(fontSize: 13)))),
        ])),
      ]),
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
  }

  Widget _buildActiveJobs(BuildContext context, int count) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.work, color: AppColors.primary, size: 24)),
        const SizedBox(width: 12),
        Expanded(child: Text('$count Active Jobs', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
        Text('$count', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
      ]),
    );
  }

  Widget _buildSystemStatus(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionHeader(title: 'System Status'),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          _statusRow(context, 'Firebase', true),
          _statusRow(context, 'Auth', true),
          _statusRow(context, 'Storage', true),
          _statusRow(context, 'Notifications', true),
        ]),
      ),
    ]);
  }

  Widget _statusRow(BuildContext context, String service, bool ok) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(service, style: Theme.of(context).textTheme.bodyMedium),
        Container(width: 8, height: 8, decoration: BoxDecoration(color: ok ? AppColors.success : AppColors.warning, shape: BoxShape.circle)),
      ]),
    );
  }
}

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

class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!, child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: double.infinity, height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
      const SizedBox(height: 16),
      Wrap(spacing: 8, runSpacing: 8, children: List.generate(4, (_) => Container(width: (MediaQuery.of(context).size.width - 40) / 2, height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))))),
    ])));
  }
}