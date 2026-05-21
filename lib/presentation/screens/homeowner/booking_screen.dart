// lib/presentation/screens/homeowner/booking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/homeowner/booking_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../widgets/common/progress_indicator.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/booking/time_slot_picker.dart';

class BookingScreen extends ConsumerWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingProvider);
    final notifier = ref.read(bookingProvider.notifier);

    // Initialize from route extra
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
      if (extra != null) notifier.init(extra);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Service', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => state.currentStep > 0 ? notifier.prevStep() : context.pop()),
      ),
      body: Column(children: [
        _Progress(current: state.currentStep),
        const Divider(),
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: _StepContent(state: state, notifier: notifier, context: context))),
        _BottomNav(state: state, notifier: notifier, onSubmit: () => _confirmBooking(context, ref, notifier)),
      ]),
    );
  }

  void _confirmBooking(BuildContext context, WidgetRef ref, BookingNotifier notifier) async {
    final user = ref.read(authProvider).user;
    final ok = await ConfirmationDialog.show(context, title: 'Confirm', message: 'Book this service?', confirmLabel: 'Confirm', icon: Icons.check_circle, onConfirm: () {}) ?? false;
    if (ok == true && user != null) {
      final success = await notifier.submitBooking(user.id);
      if (context.mounted) {
        context.showSnackBar(success ? 'Booking confirmed!' : 'Failed to book');
        if (success) context.pop();
      }
    }
  }
}

// Progress Indicator
class _Progress extends StatelessWidget {
  final int current;
  const _Progress({required this.current});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: StepProgressIndicator(currentStep: current, totalSteps: 4, labels: const ['Service', 'Schedule', 'Details', 'Confirm']),
    ).animate().fadeIn(duration: 400.ms);
  }
}

// Step Content
class _StepContent extends StatelessWidget {
  final BookingState state;
  final BookingNotifier notifier;
  final BuildContext context;
  const _StepContent({required this.state, required this.notifier, required this.context});

  @override
  Widget build(BuildContext context) {
    return switch (state.currentStep) {
      0 => _ServiceStep(services: state.services, selected: state.selectedService, onSelect: notifier.setService),
      1 => _ScheduleStep(date: state.selectedDate, time: state.selectedTime, onDate: notifier.setDate, onTime: notifier.setTime, ctx: this.context),
      2 => _DetailsStep(description: state.description, address: state.address, isEmergency: state.isEmergency, onDesc: notifier.setDescription, onAddr: notifier.setAddress, onEmergency: notifier.toggleEmergency),
      3 => _ConfirmStep(state: state),
      _ => const SizedBox(),
    };
  }
}

// Service Step
class _ServiceStep extends StatelessWidget {
  final List<String> services;
  final String selected;
  final ValueChanged<String> onSelect;
  const _ServiceStep({required this.services, required this.selected, required this.onSelect});

  IconData _icon(String s) => s.toLowerCase().contains('electric') ? Icons.electrical_services : s.toLowerCase().contains('plumb') ? Icons.plumbing : s.toLowerCase().contains('appliance') ? Icons.kitchen : s.toLowerCase().contains('ac') ? Icons.ac_unit : Icons.build;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader(title: 'Select Service'),
      const SizedBox(height: 16),
      ...services.map((s) {
        final sel = selected == s;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: sel ? AppColors.primary : Colors.transparent, width: 2)),
            tileColor: Theme.of(context).colorScheme.surface,
            leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: (sel ? AppColors.primary : Colors.grey).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(_icon(s), color: sel ? AppColors.primary : AppColors.textHint)),
            title: Text(s, style: TextStyle(fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
            trailing: sel ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
            onTap: () => onSelect(s),
          ),
        );
      }),
    ]).animate().fadeIn(duration: 400.ms);
  }
}

// Schedule Step
class _ScheduleStep extends StatelessWidget {
  final DateTime date;
  final TimeOfDay time;
  final ValueChanged<DateTime> onDate;
  final ValueChanged<TimeOfDay> onTime;
  final BuildContext ctx;
  const _ScheduleStep({required this.date, required this.time, required this.onDate, required this.onTime, required this.ctx});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader(title: 'Select Date'),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [const Icon(Icons.calendar_today, color: AppColors.primary), const SizedBox(width: 12), GestureDetector(onTap: () async { final d = await showDatePicker(context: ctx, initialDate: date, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 30))); if (d != null) onDate(d); }, child: Text(DateFormat('EEEE, MMM d, y').format(date)))]),
      ),
      const SizedBox(height: 24),
      const SectionHeader(title: 'Select Time'),
      const SizedBox(height: 16),
      TimeSlotPicker(initialTime: time, onTimeSelected: onTime),
    ]).animate().fadeIn(duration: 400.ms);
  }
}

// Details Step
class _DetailsStep extends StatelessWidget {
  final String description, address;
  final bool isEmergency;
  final ValueChanged<String> onDesc, onAddr;
  final ValueChanged<bool> onEmergency;
  const _DetailsStep({required this.description, required this.address, required this.isEmergency, required this.onDesc, required this.onAddr, required this.onEmergency});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader(title: 'Service Details'),
      const SizedBox(height: 16),
      CustomTextField(controller: TextEditingController(text: address), label: 'Service Address', hint: 'Enter your full address', prefixIcon: Icons.location_on_outlined, maxLines: 2, onChanged: onAddr),
      const SizedBox(height: 16),
      CustomTextField(controller: TextEditingController(text: description), label: 'Describe the Problem', hint: 'Explain what needs to be fixed...', prefixIcon: Icons.description_outlined, maxLines: 4, onChanged: onDesc),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: isEmergency ? AppColors.error.withOpacity(0.3) : Colors.grey.withOpacity(0.1))),
        child: Row(children: [
          Icon(isEmergency ? Icons.warning_rounded : Icons.info_outline, color: isEmergency ? AppColors.error : AppColors.textHint),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Emergency Service', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)), Text('Priority response within 2 hours', style: Theme.of(context).textTheme.bodySmall)])),
          Switch(value: isEmergency, onChanged: onEmergency, activeColor: AppColors.error),
        ]),
      ),
    ]).animate().fadeIn(duration: 400.ms);
  }
}

// Confirm Step
class _ConfirmStep extends StatelessWidget {
  final BookingState state;
  const _ConfirmStep({required this.state});

  @override
  Widget build(BuildContext context) {
    final d = DateTime(state.selectedDate.year, state.selectedDate.month, state.selectedDate.day, state.selectedTime.hour, state.selectedTime.minute);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader(title: 'Booking Summary'),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: AppColors.gradientPrimary, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          CircleAvatar(radius: 24, backgroundColor: Colors.white.withOpacity(0.2), child: Text(state.technicianName.isNotEmpty ? state.technicianName[0] : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(state.technicianName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text('\$${state.technicianRate.toStringAsFixed(0)}/hr', style: const TextStyle(color: Colors.white70))])),
          const Icon(Icons.verified, color: Colors.white),
        ]),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          _row('Service', state.selectedService),
          _row('Date', DateFormat('MMM d, y').format(d)),
          _row('Time', state.selectedTime.format(context)),
          _row('Address', state.address.isNotEmpty ? state.address : 'Not specified'),
          const Divider(),
          _row('Service Charge', '\$50.00'),
          _row('Service Fee', '\$10.00'),
          if (state.isEmergency) _row('Emergency Fee', '\$25.00'),
          const Divider(),
          _row('Total', '\$${state.estimatedPrice.toStringAsFixed(2)}', isTotal: true),
        ]),
      ),
    ]).animate().fadeIn(duration: 400.ms);
  }

  Widget _row(String l, String v, {bool isTotal = false}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)), Text(v, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? AppColors.primary : null, fontSize: isTotal ? 18 : 14))]));
  }
}

// Bottom Navigation
class _BottomNav extends StatelessWidget {
  final BookingState state;
  final BookingNotifier notifier;
  final VoidCallback onSubmit;
  const _BottomNav({required this.state, required this.notifier, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Row(children: [
        if (state.currentStep > 0) ...[Expanded(child: CustomButton(label: 'Back', isOutlined: true, onPressed: notifier.prevStep)), const SizedBox(width: 12)],
        Expanded(child: CustomButton(label: state.currentStep == 3 ? 'Confirm Booking' : 'Next', onPressed: state.currentStep == 3 ? onSubmit : notifier.nextStep, isLoading: state.isSubmitting)),
      ]),
    );
  }
}