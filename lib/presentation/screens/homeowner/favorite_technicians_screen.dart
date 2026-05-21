// lib/presentation/screens/homeowner/favorite_technicians_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/location_utils.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/homeowner/favorites_provider.dart';
import '../../widgets/technician/technician_card.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/custom_button.dart';
import '../../../routing/route_names.dart';

class FavoriteTechniciansScreen extends ConsumerWidget {
  const FavoriteTechniciansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favoritesProvider);
    final notifier = ref.read(favoritesProvider.notifier);
    final user = ref.watch(authProvider).user;

    // Load favorites when user is available
    if (user != null && !state.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => notifier.loadFavorites(user.id));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Technicians', style: TextStyle(fontWeight: FontWeight.bold))),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(state.error!),
                    const SizedBox(height: 16),
                    CustomButton(label: 'Retry', onPressed: () => user != null ? notifier.loadFavorites(user.id) : null),
                  ]),
                )
              : state.favorites.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.favorite_border,
                      title: 'No Favorites Yet',
                      message: 'Tap the heart icon on technician profiles to save them here.',
                      action: ElevatedButton(
                        onPressed: () => context.push(RouteNames.serviceList),
                        child: const Text('Browse Technicians'),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.favorites.length,
                      itemBuilder: (_, index) => _FavoriteCard(
                        tech: state.favorites[index],
                        onRemove: user != null ? (techId) => notifier.removeFavorite(user.id, techId) : null,
                        onTap: (tech) => context.push(RouteNames.booking, extra: tech),
                      ),
                    ),
    );
  }
}

// Favorite Card
class _FavoriteCard extends StatelessWidget {
  final Map<String, dynamic> tech;
  final Function(String)? onRemove;
  final Function(Map<String, dynamic>) onTap;
  const _FavoriteCard({required this.tech, this.onRemove, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(tech['id'] ?? tech['name'] as String),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        if (onRemove != null) onRemove!(tech['id'] as String);
        context.showSnackBar('${tech['name']} removed from favorites');
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TechnicianCard(
          name: tech['name'] as String,
          specialty: tech['specialty'] as String,
          rating: (tech['rating'] as num).toDouble(),
          totalJobs: (tech['totalJobs'] as num).toInt(),
          distance: LocationUtils.formatDistance((tech['distance'] as num).toDouble()),
          isAvailable: tech['isAvailable'] == true,
          onTap: () => onTap(tech),
        ),
      ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: 50 * 1)),
    );
  }
}