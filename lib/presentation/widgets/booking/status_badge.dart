// lib/presentation/widgets/booking/status_badge.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/booking.dart';

class StatusBadge extends StatelessWidget {
  final BookingStatus status;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getColor().withOpacity(0.3)),
      ),
      child: Text(
        _getLabel(),
        style: TextStyle(
          color: _getColor(),
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getLabel() {
    switch (status) {
      case BookingStatus.pending:
        return 'PENDING';
      case BookingStatus.accepted:
        return 'ACCEPTED';
      case BookingStatus.inProgress:
        return 'IN PROGRESS';
      case BookingStatus.completed:
        return 'COMPLETED';
      case BookingStatus.cancelled:
        return 'CANCELLED';
    }
  }

  Color _getColor() {
    switch (status) {
      case BookingStatus.pending:
        return AppColors.warning;
      case BookingStatus.accepted:
        return AppColors.info;
      case BookingStatus.inProgress:
        return AppColors.primary;
      case BookingStatus.completed:
        return AppColors.success;
      case BookingStatus.cancelled:
        return AppColors.error;
    }
  }
}