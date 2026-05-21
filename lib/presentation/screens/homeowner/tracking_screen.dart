// lib/presentation/screens/homeowner/tracking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../providers/homeowner/tracking_provider.dart';
import '../../widgets/common/custom_button.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  final String bookingId;
  
  const TrackingScreen({super.key, required this.bookingId});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  MapController? _mapController;

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  Future<void> _initializeTracking() async {
    await ref.read(trackingProvider.notifier).loadTracking(widget.bookingId);
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(trackingProvider);
    final notifier = ref.read(trackingProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Technician'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () => notifier.centerOnUser(),
            tooltip: 'Center on my location',
          ),
          IconButton(
            icon: const Icon(Icons.person_pin_circle),
            onPressed: trackingState.technicianLocation != null 
                ? () => notifier.centerOnTechnician()
                : null,
            tooltip: 'Center on technician',
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out_map),
            onPressed: trackingState.userLocation != null && trackingState.technicianLocation != null
                ? () => notifier.zoomToFit()
                : null,
            tooltip: 'Zoom to fit all',
          ),
        ],
      ),
      body: trackingState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : trackingState.error != null
              ? _ErrorView(
                  message: trackingState.error!,
                  onRetry: () => _initializeTracking(),
                )
              : Column(
                  children: [
                    // Map
                    Expanded(
                      flex: 3,
                      child: _buildOSMMap(trackingState, notifier),
                    ),
                    
                    // Technician Info Card
                    _TechnicianInfoCard(
                      name: trackingState.technicianName,
                      specialty: trackingState.technicianSpecialty,
                      rating: trackingState.technicianRating,
                      jobs: trackingState.technicianJobs,
                      phone: trackingState.technicianPhone,
                      distance: trackingState.distance,
                      eta: trackingState.eta,
                      onCall: () {
                        // TODO: Implement call functionality
                        context.showSnackBar('Calling technician...');
                      },
                      onMessage: () {
                        // TODO: Navigate to chat
                        context.showSnackBar('Opening chat...');
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Status and actions
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              label: 'Cancel Tracking',
                              isOutlined: true,
                              onPressed: () {
                                notifier.stopListening();
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              label: 'Share Location',
                              icon: Icons.share,
                              onPressed: () {
                                //Share location functionality
                                
                                context.showSnackBar('Sharing location...');
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildOSMMap(TrackingState state, TrackingNotifier notifier) {
    return OSMFlutter(
      controller: MapController(
        initMapWithUserPosition: null,
        initPosition: state.userLocation ??
            GeoPoint(latitude: -6.369028, longitude: 34.888822),
      ),
      osmOption: OSMOption(
        enableRotationByGesture: true,
        zoomOption: const ZoomOption(
          initZoom: 14,
          minZoomLevel: 8,
          maxZoomLevel: 18,
        ),
        userLocationMarker: UserLocationMaker(
          personMarker: const MarkerIcon(
            icon: Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
          ),
          directionArrowMarker: const MarkerIcon(
            icon: Icon(Icons.navigation, color: Colors.blue, size: 30),
          ),
        ),
        roadConfiguration: const RoadOption(
          roadColor: AppColors.primary,
          roadWidth: 4,
        ),
      ),
      onMapIsReady: (bool isReady) async {
        // Draw initial markers now that the native map is ready
        if (state.userLocation != null) {
          await _mapController!.addMarker(
            GeoPoint(
              latitude: state.userLocation!.latitude,
              longitude: state.userLocation!.longitude,
            ),
            markerIcon: const MarkerIcon(
              icon: Icon(Icons.home, color: Colors.blue, size: 40),
            ),
          );
        }

        if (state.technicianLocation != null) {
          await _mapController!.addMarker(
            GeoPoint(
              latitude: state.technicianLocation!.latitude,
              longitude: state.technicianLocation!.longitude,
            ),
            markerIcon: const MarkerIcon(
              icon: Icon(Icons.directions_car, color: AppColors.primary, size: 40),
            ),
          );
        }

        // Draw the initial route
        if (state.userLocation != null && state.technicianLocation != null) {
          await _mapController!.clearAllRoads();
          final pts = state.routePoints;
          if (pts.length >= 2) {
            await _mapController!.drawRoadManually(
              pts,
              const RoadOption(roadColor: AppColors.primary, roadWidth: 4),
            );
          }
          // Zoom to fit both points
          final points = [
            GeoPoint(
              latitude: state.userLocation!.latitude,
              longitude: state.userLocation!.longitude,
            ),
            GeoPoint(
              latitude: state.technicianLocation!.latitude,
              longitude: state.technicianLocation!.longitude,
            ),
          ];
          await _mapController!.zoomToBoundingBox(
            BoundingBox.fromGeoPoints(points),
            paddinInPixel: 50,
          );
        }

        // Let the provider own the controller for real-time updates
        notifier.setMapController(_mapController!);
      },
    );
  }
}

// Technician Info Card Widget
class _TechnicianInfoCard extends StatelessWidget {
  final String name;
  final String specialty;
  final double rating;
  final int jobs;
  final String phone;
  final double distance;
  final String eta;
  final VoidCallback onCall;
  final VoidCallback onMessage;

  const _TechnicianInfoCard({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.jobs,
    required this.phone,
    required this.distance,
    required this.eta,
    required this.onCall,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.engineering, color: AppColors.primary, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(specialty, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text('$rating', style: const TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(width: 8),
                        const Icon(Icons.work, color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Text('$jobs jobs', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),
              // Call & Message buttons
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.call, color: AppColors.primary),
                    onPressed: onCall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.message, color: AppColors.primary),
                    onPressed: onMessage,
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Icon(Icons.directions_car, color: Colors.grey, size: 20),
                    const SizedBox(height: 4),
                    Text('${distance.toStringAsFixed(1)} km', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Text('Distance', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Icon(Icons.access_time, color: Colors.grey, size: 20),
                    const SizedBox(height: 4),
                    Text(eta, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Text('ETA', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Error View Widget
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            CustomButton(label: 'Retry', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}