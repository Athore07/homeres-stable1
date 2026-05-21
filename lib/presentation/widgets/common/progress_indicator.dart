// lib/presentation/widgets/common/progress_indicator.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String>? labels;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompleted = index < currentStep;
            final isCurrent = index == currentStep;
            
            return Expanded(
              child: Row(
                children: [
                  if (index > 0)
                    Expanded(
                      child: Container(
                        height: 3,
                        color: isCompleted ? AppColors.primary : Colors.grey[200],
                      ),
                    ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? AppColors.primary
                          : (isCurrent ? AppColors.primary : Colors.grey[200]),
                      border: isCurrent
                          ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 4)
                          : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isCurrent ? Colors.white : AppColors.textHint,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        if (labels != null) ...[
          const SizedBox(height: 8),
          Row(
            children: labels!.map((label) => Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: AppColors.textHint),
              ),
            )).toList(),
          ),
        ],
      ],
    );
  }
}