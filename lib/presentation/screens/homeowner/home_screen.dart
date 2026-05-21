// lib/presentation/screens/homeowner/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/location_utils.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/homeowner/home_provider.dart';
import '../../widgets/common/badge_icon.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/drawer/app_drawer.dart';
import '../../widgets/technician/technician_card.dart';
import '../../../routing/route_names.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    ref.read(homeProvider.notifier).stopListening();
    super.dispose();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    return h < 6 ? 'Good Night' : h < 12 ? 'Good Morning' : h < 17 ? 'Good Afternoon' : 'Good Evening';
  }

  void _openSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: _HomeSearchDelegate(
        services: ref.read(homeProvider).services,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final state = ref.watch(homeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Text('Homeres', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () => _openSearch(context)),
          const SizedBox(width: 12),
          BadgeIcon(icon: Icons.chat, count: 3, iconColor: Colors.white, onTap: () => context.push(RouteNames.notifications)),
          const SizedBox(width: 15),
        ],
      ),
      drawer: const AppDrawer(),
      body: state.isLoading
          ? const _Shimmer()
          : CustomScrollView(slivers: [
              // === Header greeting ===
              _Header(
                user: user?.name ?? 'User',
                greeting: _greeting(),
                message: 'What service you need assistance with?',
                
              ),

              // === Promo banner on top (right after header) ===
              const SliverToBoxAdapter(child: _PromoBanner()),

              // === Location card ===
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _LocationCard(address: state.currentAddress),
              )),

              // === Mostly Searched services (2-column grid) ===
              if (state.services.isNotEmpty)
                _ServicesGridSection(
                  services: state.services,
                  onSeeAll: () => context.push(RouteNames.serviceList),
                ),

              // === Nearby technicians ===
              if (state.nearbyTechnicians.isNotEmpty)
                SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SectionHeader(title: 'Nearby Technicians', actionLabel: 'See All', onActionTap: () => context.push(RouteNames.serviceList)),
                    const SizedBox(height: 8),
                    SizedBox(height: 110, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: state.nearbyTechnicians.length, itemBuilder: (_, i) => _TechMiniCard(tech: state.nearbyTechnicians[i], onTap: () => context.push(RouteNames.booking, extra: state.nearbyTechnicians[i])))),
                  ]),
                )),

              // === Top rated technicians ===
              if (state.topTechnicians.isNotEmpty)
                SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SectionHeader(title: 'Top Rated', actionLabel: 'View All', onActionTap: () => context.push(RouteNames.serviceList)),
                    const SizedBox(height: 8),
                    ...state.topTechnicians.take(3).map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TechnicianCard(
                            name: t['name'] as String,
                            specialty: t['specialty'] as String,
                            rating: (t['rating'] as num).toDouble(),
                            totalJobs: (t['totalJobs'] as num).toInt(),
                            distance: LocationUtils.formatDistance((t['distance'] as num).toDouble()),
                            isAvailable: t['isAvailable'] == true,
                            onTap: () => context.push(RouteNames.booking, extra: t),
                          ),
                        )),
                  ]),
                )),

              // === Partial map preview at the bottom ===
              SliverToBoxAdapter(child: _PartialMapPreview(
                latitude: state.latitude,
                longitude: state.longitude,
                nearbyTechs: state.nearbyTechnicians.take(6).toList(),
              )),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ]),
    );
  }
}

// ===================================================================
// Search delegate used by the AppBar search icon
// ===================================================================
class _HomeSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> services;
  _HomeSearchDelegate({required this.services});

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, ''),
      );

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    final results = query.isEmpty
        ? services
        : services.where((s) {
            final name = (s['name'] as String).toLowerCase();
            return name.contains(query.toLowerCase());
          }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, i) {
        final s = results[i];
        return ListTile(
          leading: BadgeIcon(icon: s['icon'] as IconData, count: 0),
          title: Text(s['name'] as String),
          subtitle: Text(s['category'] as String? ?? ''),
          trailing: Text('\$${(s['basePrice'] as num).toStringAsFixed(0)}/hr',
              style: const TextStyle(color: AppColors.primary)),
          onTap: () => context.push(RouteNames.booking),
        );
      },
    );
  }
}

// ===================================================================
// Header widget
// ===================================================================
class _Header extends StatelessWidget {
  final String user, greeting, message;
  
  const _Header({required this.user, required this.greeting, required this.message});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Text('$greeting 👋', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
            Text(user, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 16),
          // welcome message or question
          Text(message, style: const TextStyle(fontSize: 16,)),
        ]),
      ),
    );
  }
}

// ===================================================================
// Location card
// ===================================================================
class _LocationCard extends StatelessWidget {
  final String address;
  const _LocationCard({required this.address});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Your Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 2),
            Text(address, style: TextStyle(color: Colors.grey[500], fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
          ])),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ]),
      ),
    );
  }
}

// ===================================================================
// Services grid section — Mostly Searched
// ===================================================================
class _ServicesGridSection extends StatelessWidget {
  final List<Map<String, dynamic>> services;
  final VoidCallback onSeeAll;
  const _ServicesGridSection({required this.services, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionHeader(title: 'Mostly Searched', actionLabel: 'See All', onActionTap: onSeeAll),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.05,
            ),
            itemCount: services.length,
            itemBuilder: (_, i) => _ServiceCard(
              service: services[i],
              onSeeAll: onSeeAll,
            ),
          ),
        ]),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final VoidCallback onSeeAll;
  const _ServiceCard({required this.service, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final color = service['color'] as Color;
    return GestureDetector(
      onTap: () => context.push(RouteNames.booking),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
            child: Icon((service['icon'] as IconData?) ?? Icons.build, color: color, size: 26),
          ),
          const SizedBox(height: 12),
          Text(service['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}

// ===================================================================
// Partial map preview at bottom
// ===================================================================
class _PartialMapPreview extends StatelessWidget {
  final double latitude, longitude;
  final List<Map<String, dynamic>> nearbyTechs;
  const _PartialMapPreview({required this.latitude, required this.longitude, required this.nearbyTechs});

  Future<void> _onTapMap(BuildContext context) async {
    // Navigate to the tracking route with the current user's location; the
    // tracking screen will use `loadTracking` to show the full OSM map.
    // A bookingId of '' (empty string) results in the default location being
    // used inside the provider while the map is fully initialised.
    if (context.mounted) {
      context.push(RouteNames.tracking);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onTapMap(context),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(fit: StackFit.expand, children: [
          OSMFlutter(
            controller: MapController.withPosition(
              initPosition: GeoPoint(latitude: latitude, longitude: longitude),
            ),
            osmOption: OSMOption(
              zoomOption: const ZoomOption(initZoom: 13, minZoomLevel: 8, maxZoomLevel: 15),
              userTrackingOption: const UserTrackingOption(enableTracking: false),
              roadConfiguration: const RoadOption(roadColor: AppColors.primary, roadWidth: 3, zoomInto: false),
              showZoomController: false,
            ),
          ),
          // Gradient overlay
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black26],
                stops: [0.6, 1.0],
              ),
            ),
            child: SizedBox.expand(),
          ),
          // "Nearby Map" tap label
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withAlpha(220), borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: const [
                  Icon(Icons.map_outlined, size: 14, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text('Tap to view Live Map', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ===================================================================
// Tech mini card
// ===================================================================
class _TechMiniCard extends StatelessWidget {
  final Map<String, dynamic> tech;
  final VoidCallback onTap;
  const _TechMiniCard({required this.tech, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160, margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.withOpacity(0.1))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(radius: 16, backgroundColor: AppColors.primary.withOpacity(0.1), child: Text((tech['name'] as String)[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12))),
            const SizedBox(width: 6),
            Expanded(child: Text(tech['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11), overflow: TextOverflow.ellipsis)),
          ]),
          const Spacer(),
          Text(tech['specialty'] as String, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [const Icon(Icons.star, color: Colors.amber, size: 11), Text('${(tech['rating'] as num).toStringAsFixed(1)}', style: const TextStyle(fontSize: 10))]),
            Text(LocationUtils.formatDistance((tech['distance'] as num).toDouble()), style: const TextStyle(fontSize: 9, color: Colors.grey)),
          ]),
        ]),
      ),
    );
  }
}

// ===================================================================
// Promo banner — now placed right after the header on the home screen
// ===================================================================
class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        height: 100,
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFFF8C5A)]), borderRadius: BorderRadius.circular(20)),
        child: Stack(children: [
          Positioned(right: -10, top: -10, child: Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle))),
          Padding(padding: const EdgeInsets.all(16), child: Row(children: [
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('SPECIAL OFFER', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
              SizedBox(height: 4),
              Text('Get 20% off', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text('on first booking!', style: TextStyle(color: Colors.white70, fontSize: 11)),
            ])),
            ElevatedButton(
              onPressed: () => context.push(RouteNames.serviceList),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFFF6B35), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              child: const Text('Book Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ])),
        ]),
      ),
    );
  }
}

// ===================================================================
// Shimmer loading placeholder
// ===================================================================
class _Shimmer extends StatelessWidget {
  const _Shimmer();
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(children: [
          Container(height: 150, color: Colors.white),
          const SizedBox(height: 16),
          Container(margin: const EdgeInsets.all(16), height: 180, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
        ]),
      ),
    );
  }
}
