// lib/presentation/screens/homeowner/service_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routing/route_names.dart';
import '../../providers/homeowner/service_list_provider.dart';

class ServiceListScreen extends ConsumerStatefulWidget {
  const ServiceListScreen({super.key});

  @override
  ConsumerState<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends ConsumerState<ServiceListScreen> {
  @override
  void initState() {
    super.initState();
    // Real-time listeners start automatically
  }

  @override
  void dispose() {
    // Stop listeners when leaving screen
    ref.read(serviceListProvider.notifier).stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(serviceListProvider);
    final notifier = ref.read(serviceListProvider.notifier);

    return Scaffold(
      body: state.isLoading && state.services.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(slivers: [
              SliverAppBar(
                floating: true, snap: true,
                title: const Text('Services', style: TextStyle(fontWeight: FontWeight.bold)),
                actions: [
                  IconButton(
                    icon: Icon(state.isGridView ? Icons.list : Icons.grid_view),
                    onPressed: notifier.toggleView,
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: Column(children: [
                    // Search Bar
                    GestureDetector(
                      onTap: () => context.push(RouteNames.search),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(children: [
                          Icon(Icons.search, color: Colors.grey[400], size: 20),
                          const SizedBox(width: 10),
                          Text('Search services...', style: TextStyle(color: Colors.grey[400])),
                        ]),
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                    const SizedBox(height: 12),

                    // Category Filter
                    if (state.categories.isNotEmpty)
                      _CategoryFilter(
                        categories: state.categories,
                        selected: state.selectedCategory,
                        onSelected: notifier.setCategory,
                      ),
                    const SizedBox(height: 20),

                    // Technicians Highlight
                    if (state.technicians.isNotEmpty) ...[
                      Text('Top Technicians', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 160,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: state.technicians.take(5).map((t) => _TechCard(
                            tech: t,
                            onTap: () => context.push(RouteNames.booking, extra: t),
                          )).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // All Services
                    Text('All Categories', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    state.isGridView
                        ? _ServiceGrid(
                            services: state.filteredServices,
                            onTap: (s) => context.push(RouteNames.serviceDetail, extra: s),
                          )
                        : _ServiceList(
                            services: state.filteredServices,
                            onTap: (s) => context.push(RouteNames.serviceDetail, extra: s),
                          ),
                  ]),
                ),
              ),
            ]),
    );
  }
}

// Category Filter
class _CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;
  const _CategoryFilter({required this.categories, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(scrollDirection: Axis.horizontal, children: categories.map((c) {
        final sel = selected == c;
        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: GestureDetector(
            onTap: () => onSelected(c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: sel ? AppColors.primary : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: sel ? AppColors.primary : Colors.grey.withOpacity(0.15)),
              ),
              child: Text(c, style: TextStyle(color: sel ? Colors.white : null, fontWeight: FontWeight.w600, fontSize: 11)),
            ),
          ),
        );
      }).toList()),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// Technician Card
class _TechCard extends StatelessWidget {
  final Map<String, dynamic> tech;
  final VoidCallback onTap;
  const _TechCard({required this.tech, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240, margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.85), AppColors.primaryDark]),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(radius: 20, backgroundColor: Colors.white.withOpacity(0.2), child: Text((tech['name'] as String)[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.star, color: Colors.amber, size: 12),
                const SizedBox(width: 2),
                Text('${(tech['rating'] as num).toStringAsFixed(1)}', style: const TextStyle(color: Colors.white, fontSize: 11)),
              ]),
            ),
          ]),
          const Spacer(),
          Text(tech['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          Text(tech['specialty'] as String, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
          const SizedBox(height: 6),
          Text('\$${tech['hourlyRate']}/hr • ${tech['totalJobs']} jobs', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
        ]),
      ),
    );
  }
}

// Service Grid
class _ServiceGrid extends StatelessWidget {
  final List<Map<String, dynamic>> services;
  final Function(Map<String, dynamic>) onTap;
  const _ServiceGrid({required this.services, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.82, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: services.length,
      itemBuilder: (_, i) => _ServiceCard(service: services[i], onTap: () => onTap(services[i])),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final VoidCallback onTap;
  const _ServiceCard({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = service['color'] as Color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10)), child: Icon(service['icon'] as IconData, color: color, size: 24)),
          const Spacer(),
          Text(service['name'] as String, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(service['description'] as String, style: TextStyle(color: Colors.grey[500], fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Text('\$${(service['basePrice'] as num).toStringAsFixed(0)}/hr', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
        ]),
      ),
    );
  }
}

// Service List
class _ServiceList extends StatelessWidget {
  final List<Map<String, dynamic>> services;
  final Function(Map<String, dynamic>) onTap;
  const _ServiceList({required this.services, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      itemBuilder: (_, i) {
        final s = services[i];
        return GestureDetector(
          onTap: () => onTap(s),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: (s['color'] as Color).withOpacity(0.08), borderRadius: BorderRadius.circular(10)), child: Icon(s['icon'] as IconData, color: s['color'] as Color, size: 24)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s['name'] as String, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                Text(s['description'] as String, style: TextStyle(color: Colors.grey[500], fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('\$${(s['basePrice'] as num).toStringAsFixed(0)}/hr', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
              ])),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ]),
          ),
        );
      },
    );
  }
}