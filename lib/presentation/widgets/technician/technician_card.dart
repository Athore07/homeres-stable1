// lib/presentation/widgets/technician/technician_card.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class TechnicianCard extends StatelessWidget {
  final String name;
  final String specialty;
  final double rating;
  final int totalJobs;
  final String distance;
  final String? imageUrl;
  final bool isAvailable;
  final VoidCallback? onTap;

  const TechnicianCard({
    super.key,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.totalJobs,
    required this.distance,
    this.imageUrl,
    required this.isAvailable,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile image/avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
                  child: imageUrl == null
                      ? Text(
                          name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
                // Online indicator
                if (isAvailable)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Technician info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.textHint.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isAvailable ? 'Available' : 'Busy',
                          style: TextStyle(
                            color: isAvailable ? AppColors.success : AppColors.textHint,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    specialty,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Rating
                      Icon(Icons.star, color: AppColors.accent, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$rating',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Job count
                      Icon(Icons.work_outline, size: 14, 
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                      const SizedBox(width: 4),
                      Text(
                        '$totalJobs jobs',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                      const Spacer(),
                      // Distance
                      Icon(Icons.location_on_outlined, size: 14,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                      const SizedBox(width: 4),
                      Text(
                        distance,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}