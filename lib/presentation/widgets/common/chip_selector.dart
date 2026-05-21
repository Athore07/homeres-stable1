// lib/presentation/widgets/common/chip_selector.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ChipSelector<T> extends StatelessWidget {
  final List<T> items;
  final T? selectedItem;
  final String Function(T) labelBuilder;
  final IconData? Function(T)? iconBuilder;
  final void Function(T) onSelected;
  final bool scrollable;
  final Color? selectedColor;

  const ChipSelector({
    super.key,
    required this.items,
    this.selectedItem,
    required this.labelBuilder,
    this.iconBuilder,
    required this.onSelected,
    this.scrollable = true,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final chips = items.map((item) {
      final isSelected = item == selectedItem;
      final icon = iconBuilder?.call(item);
      
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null && isSelected) ...[
                Icon(icon, size: 16, color: Colors.white),
                const SizedBox(width: 4),
              ],
              Text(labelBuilder(item)),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) onSelected(item);
          },
          selectedColor: selectedColor ?? AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : null,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          side: BorderSide(
            color: isSelected
                ? (selectedColor ?? AppColors.primary)
                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        ),
      );
    }).toList();

    if (scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: chips),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }
}