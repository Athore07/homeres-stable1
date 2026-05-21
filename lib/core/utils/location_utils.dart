// lib/core/utils/location_utils.dart
import 'dart:math';
import 'package:geocoding/geocoding.dart';

class LocationUtils {
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    const double earthRadius = 6371;
    final dLat = _toRadians(endLatitude - startLatitude);
    final dLon = _toRadians(endLongitude - startLongitude);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(startLatitude)) *
            cos(_toRadians(endLatitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degree) => degree * pi / 180;

  static String formatDistance(double km) {
    if (km < 1) {
      return '${(km * 1000).round()}m';
    }
    return '${km.toStringAsFixed(1)}km';
  }

  static String getEstimatedTime(double distanceKm) {
    // Assume average speed of 30 km/h in city
    final minutes = (distanceKm / 30 * 60).round();
    if (minutes < 1) return 'Less than a minute';
    if (minutes == 1) return '1 minute';
    if (minutes < 60) return '$minutes mins';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) return '$hours hr';
    return '$hours hr $remainingMinutes mins';
  }
  
  static Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street ?? place.name ?? ''}, ${place.locality ?? ''}';
      }
      return 'Location found';
    } catch (e) {
      return 'Unable to get address';
    }
  }
}
