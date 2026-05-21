// lib/presentation/widgets/booking/time_slot_picker.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class TimeSlotPicker extends StatefulWidget {
  final Function(TimeOfDay) onTimeSelected;
  final TimeOfDay? initialTime;

  const TimeSlotPicker({
    super.key,
    required this.onTimeSelected,
    this.initialTime,
  });

  @override
  State<TimeSlotPicker> createState() => _TimeSlotPickerState();
}

class _TimeSlotPickerState extends State<TimeSlotPicker> {
  TimeOfDay? _selectedTime;
  
  final List<TimeOfDay> _morningSlots = [
    const TimeOfDay(hour: 8, minute: 0),
    const TimeOfDay(hour: 9, minute: 0),
    const TimeOfDay(hour: 10, minute: 0),
    const TimeOfDay(hour: 11, minute: 0),
  ];
  
  final List<TimeOfDay> _afternoonSlots = [
    const TimeOfDay(hour: 12, minute: 0),
    const TimeOfDay(hour: 13, minute: 0),
    const TimeOfDay(hour: 14, minute: 0),
    const TimeOfDay(hour: 15, minute: 0),
    const TimeOfDay(hour: 16, minute: 0),
  ];
  
  final List<TimeOfDay> _eveningSlots = [
    const TimeOfDay(hour: 17, minute: 0),
    const TimeOfDay(hour: 18, minute: 0),
    const TimeOfDay(hour: 19, minute: 0),
  ];

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTimeGroup(context, 'Morning', _morningSlots),
        const SizedBox(height: 12),
        _buildTimeGroup(context, 'Afternoon', _afternoonSlots),
        const SizedBox(height: 12),
        _buildTimeGroup(context, 'Evening', _eveningSlots),
      ],
    );
  }

  Widget _buildTimeGroup(BuildContext context, String title, List<TimeOfDay> slots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.textHint,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: slots.map((time) {
            final isSelected = _selectedTime == time;
            final formattedTime = time.format(context);
            
            return GestureDetector(
              onTap: () {
                setState(() => _selectedTime = time);
                widget.onTimeSelected(time);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  formattedTime,
                  style: TextStyle(
                    color: isSelected ? Colors.white : null,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}