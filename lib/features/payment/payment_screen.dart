// lib/presentation/screens/payment/payment_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../presentation/widgets/common/custom_button.dart';

class PaymentScreen extends StatelessWidget {
  final Map<String, dynamic> bookingDetails;
  
  const PaymentScreen({super.key, required this.bookingDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Booking Summary', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const Divider(),
                  _buildSummaryRow(context, 'Service', bookingDetails['service'] ?? 'Electrical Repair'),
                  _buildSummaryRow(context, 'Technician', bookingDetails['technician'] ?? 'John Doe'),
                  _buildSummaryRow(context, 'Date', bookingDetails['date'] ?? 'Today'),
                  _buildSummaryRow(context, 'Time', bookingDetails['time'] ?? '10:00 AM'),
                  const Divider(),
                  _buildSummaryRow(context, 'Service Charge', '\$50.00'),
                  _buildSummaryRow(context, 'Service Fee', '\$10.00'),
                  _buildSummaryRow(context, 'Total', '\$60.00', isTotal: true),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 24),
            
            // Payment methods
            Text('Payment Method', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))
              .animate().fadeIn(duration: 400.ms, delay: 200.ms),
            const SizedBox(height: 12),
            _buildPaymentMethod(context, Icons.credit_card, 'Credit/Debit Card', '**** 4242', true)
              .animate().fadeIn(duration: 400.ms, delay: 300.ms),
            _buildPaymentMethod(context, Icons.account_balance, 'Bank Transfer', 'Direct bank payment', false)
              .animate().fadeIn(duration: 400.ms, delay: 400.ms),
            _buildPaymentMethod(context, Icons.phone_android, 'Mobile Money', 'M-Pesa, Airtel Money', false)
              .animate().fadeIn(duration: 400.ms, delay: 500.ms),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Add New Payment Method'),
            ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
            const SizedBox(height: 32),
            
            // Pay button
            CustomButton(
              label: 'Pay \$60.00',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    icon: const Icon(Icons.check_circle, color: AppColors.success, size: 64),
                    title: const Text('Payment Successful!'),
                    content: const Text('Your booking has been confirmed. The technician will arrive at the scheduled time.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                );
              },
            ).animate().fadeIn(duration: 400.ms, delay: 700.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.primary : null,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(BuildContext context, IconData icon, String title, String subtitle, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.05) : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textHint)),
              ],
            ),
          ),
          if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary),
        ],
      ),
    );
  }
}

// lib/presentation/screens/payment/payment_methods_screen.dart
class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<Map<String, dynamic>> _paymentMethods = [
    {'type': 'Visa', 'number': '**** **** **** 4242', 'expiry': '12/26', 'isDefault': true},
    {'type': 'Mastercard', 'number': '**** **** **** 5555', 'expiry': '06/25', 'isDefault': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _paymentMethods.length,
        itemBuilder: (context, index) {
          return _buildCard(context, _paymentMethods[index], index);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCardDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Card'),
      ),
    );
  }

  Widget _buildCard(BuildContext context, Map<String, dynamic> card, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(card['type'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              if (card['isDefault'])
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Default', style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(card['number'], style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 2)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Expires: ${card['expiry']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Row(
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text('Edit', style: TextStyle(color: Colors.white)),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _paymentMethods.removeAt(index));
                    },
                    child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(
      duration: 400.ms,
      delay: Duration(milliseconds: index * 100),
    );
  }

  void _showAddCardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add New Card'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Card Number',
                hintText: '1234 5678 9012 3456',
                prefixIcon: Icon(Icons.credit_card),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Expiry',
                      hintText: 'MM/YY',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'CVV',
                      hintText: '123',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Add Card')),
        ],
      ),
    );
  }
}

// lib/presentation/screens/payment/invoice_screen.dart
class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          IconButton(icon: const Icon(Icons.download), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Company header
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.home_repair_service, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('HOMERES', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const Text('support@homeres.com', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                    ],
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 32),
            
            // Invoice details
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('INVOICE', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('#INV-2024-001', style: Theme.of(context).textTheme.titleSmall),
                          const Text('Date: 2024-01-15', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildInvoiceRow(context, 'Service', 'Electrical Repair'),
                  _buildInvoiceRow(context, 'Technician', 'John Doe'),
                  _buildInvoiceRow(context, 'Duration', '2 hours'),
                  _buildInvoiceRow(context, 'Rate', '\$50.00/hr'),
                  const Divider(height: 24),
                  _buildInvoiceRow(context, 'Subtotal', '\$100.00'),
                  _buildInvoiceRow(context, 'Service Fee', '\$10.00'),
                  _buildInvoiceRow(context, 'Tax (5%)', '\$5.50'),
                  const Divider(height: 24),
                  _buildInvoiceRow(context, 'Total', '\$115.50', isTotal: true),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
            const SizedBox(height: 32),
            
            // Payment status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: AppColors.success),
                  SizedBox(width: 8),
                  Text('Payment Completed', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(BuildContext context, String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 18 : 14)),
          Text(value, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 18 : 14, color: isTotal ? AppColors.primary : null)),
        ],
      ),
    );
  }
}