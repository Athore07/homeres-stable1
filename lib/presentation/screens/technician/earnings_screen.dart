// lib/presentation/screens/technician/earnings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/technician/earnings_provider.dart';
import '../../widgets/common/empty_state_widget.dart';

class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  @override
  void initState() {
    super.initState();
    // Start listening when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user != null) {
        ref.read(earningsProvider.notifier).startListening(user.id);
      }
    });
  }

  @override
  void dispose() {
    // Stop listening when screen closes
    ref.read(earningsProvider.notifier).stopListening();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000) return '\$${(amount / 1000).toStringAsFixed(1)}K';
    return '\$${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(earningsProvider);
    final notifier = ref.read(earningsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Earnings', style: TextStyle(fontWeight: FontWeight.bold))),
      body: state.isLoading && state.transactions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text("An error occurred while fetching earnings. Please make sure you setup profile and try again.", style: const TextStyle(color: AppColors.error)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    // Total Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(gradient: AppColors.gradientPrimary, borderRadius: BorderRadius.circular(20)),
                      child: Column(children: [
                        const Text('Total Earnings', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 8),
                        Text(_formatCurrency(state.filteredTotal), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('${state.filteredTransactions.length} completed jobs', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                      ]),
                    ),
                    const SizedBox(height: 16),

                    // Period Filter
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: ['This Week', 'This Month', 'This Year', 'All Time'].map((p) {
                        final sel = state.selectedPeriod == p;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(p, style: TextStyle(color: sel ? Colors.white : null, fontWeight: FontWeight.w600, fontSize: 12)),
                            selected: sel,
                            onSelected: (_) => notifier.setPeriod(p),
                            selectedColor: AppColors.primary,
                          ),
                        );
                      }).toList()),
                    ).animate().fadeIn(duration: 400.ms),

                    const SizedBox(height: 20),

                    // Transactions List
                    if (state.filteredTransactions.isEmpty)
                      const EmptyStateWidget(icon: Icons.receipt_long, title: 'No Transactions', message: 'No earnings in this period')
                    else
                      ...state.filteredTransactions.map((t) => _TransactionCard(transaction: t)),
                  ]),
                ),
    );
  }
}

// Transaction Card
class _TransactionCard extends StatelessWidget {
  final Map<String, dynamic> transaction;
  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.success.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.payment_rounded, color: AppColors.success, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(transaction['service'] as String, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(transaction['customer'] as String, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            const SizedBox(height: 2),
            Text(DateFormat('MMM dd, yyyy').format(transaction['date'] as DateTime), style: TextStyle(color: Colors.grey[400], fontSize: 10)),
          ]),
        ),
        Text('\$${(transaction['amount'] as double).toStringAsFixed(2)}', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 15)),
      ]),
    ).animate().fadeIn(duration: 300.ms);
  }
}