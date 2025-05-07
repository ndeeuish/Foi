import 'dart:convert';
import 'dart:math';
import 'package:foi/auth/services/geocoding_service.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class DistanceService {
  final Map<String, double> _distanceCache = {};

  double calculateHaversineDistance(LatLng origin, LatLng destination) {
    const earthRadius = 6371;
    final dLat = (destination.latitude - origin.latitude) * pi / 180;
    final dLon = (destination.longitude - origin.longitude) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(origin.latitude * pi / 180) *
            cos(destination.latitude * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadius * c;
    print(
        'DistanceService - Haversine distance: ${distance.toStringAsFixed(2)}km');
    return distance;
  }

  Future<double> getDistanceFromOSRM(LatLng origin, LatLng destination) async {
    final cacheKey =
        '${origin.latitude},${origin.longitude};${destination.latitude},${destination.longitude}';
    if (_distanceCache.containsKey(cacheKey)) {
      print(
          'DistanceService - Using cached distance: ${_distanceCache[cacheKey]}km');
      return _distanceCache[cacheKey]!;
    }

    final haversineDistance = calculateHaversineDistance(origin, destination);
    if (haversineDistance < 5 || haversineDistance > 50) {
      _distanceCache[cacheKey] = haversineDistance;
      return haversineDistance;
    }

    final url = 'http://router.project-osrm.org/route/v1/driving/'
        '${origin.longitude},${origin.latitude};'
        '${destination.longitude},${destination.latitude}'
        '?overview=false';
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 'Ok') {
          final distanceInMeters = data['routes'][0]['distance'];
          final distance = distanceInMeters / 1000;
          _distanceCache[cacheKey] = distance;
          print(
              'DistanceService - OSRM distance: ${distance.toStringAsFixed(2)}km');
          return distance;
        }
        throw Exception('OSRM returned invalid status: ${data['code']}');
      }
      throw Exception('Failed to fetch distance: ${response.statusCode}');
    } catch (e) {
      print('DistanceService - OSRM API error: $e');
      _distanceCache[cacheKey] = haversineDistance;
      return haversineDistance;
    }
  }

  Future<double> fetchDistance(String address, LatLng defaultRestaurantLocation,
      GeocodingService geocodingService) async {
    if (address.trim().isEmpty) {
      print('DistanceService - Empty address, distance set to 0.0');
      return 0.0;
    }
    try {
      final customerLocation =
          await geocodingService.getCoordinatesWithFallback(address);
      final cacheKey =
          '${defaultRestaurantLocation.latitude},${defaultRestaurantLocation.longitude};${customerLocation.latitude},${customerLocation.longitude}';
      if (_distanceCache.containsKey(cacheKey)) {
        print(
            'DistanceService - Using cached distance: ${_distanceCache[cacheKey]} km for address: $address');
        return _distanceCache[cacheKey]!;
      }
      final distance = await getDistanceFromOSRM(
          defaultRestaurantLocation, customerLocation);
      print(
          'DistanceService - Fetched distance: ${distance.toStringAsFixed(2)} km for address: $address');
      return distance;
    } catch (e) {
      print('DistanceService - Error fetching distance: $e');
      throw e;
    }
  }
}
