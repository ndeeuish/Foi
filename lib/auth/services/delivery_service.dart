import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

class DeliveryService with ChangeNotifier {
  final LatLng defaultRestaurantLocation =
      const LatLng(21.0045, 105.8428); // Hanoi
  String _estimatedTime = "N/A";
  String _deliveryFee = "N/A";

  // Cache for geocoding and distances
  final Map<String, LatLng> _geocodeCache = {};
  final Map<String, double> _distanceCache = {};

  String get estimatedTime => _estimatedTime;
  String get deliveryFee => _deliveryFee;

  // Haversine formula for distance (fallback)
  double calculateHaversineDistance(LatLng origin, LatLng destination) {
    const earthRadius = 6371; // km
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
        'DeliveryService - Haversine distance: ${distance.toStringAsFixed(2)}km');
    return distance;
  }

  // Get distance via OSRM with cache
  Future<double> getDistanceFromOSRM(LatLng origin, LatLng destination) async {
    final cacheKey =
        '${origin.latitude},${origin.longitude};${destination.latitude},${destination.longitude}';
    if (_distanceCache.containsKey(cacheKey)) {
      print(
          'DeliveryService - Using cached distance: ${_distanceCache[cacheKey]}km');
      return _distanceCache[cacheKey]!;
    }

    // Fallback to Haversine for short or very long distances
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
              'DeliveryService - OSRM distance: ${distance.toStringAsFixed(2)}km');
          return distance;
        }
        throw Exception('OSRM returned invalid status: ${data['code']}');
      }
      throw Exception('Failed to fetch distance: ${response.statusCode}');
    } catch (e) {
      print('DeliveryService - OSRM API error: $e');
      _distanceCache[cacheKey] = haversineDistance;
      return haversineDistance; // Fallback
    }
  }

  // Get coordinates from address with cache and Vietnam-only validation
  Future<LatLng> getCoordinatesFromAddress(String address) async {
    if (_geocodeCache.containsKey(address)) {
      print(
          'DeliveryService - Using cached coordinates for "$address": ${_geocodeCache[address]}');
      return _geocodeCache[address]!;
    }

    final url =
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeQueryComponent(address)}&format=json&limit=1&addressdetails=1&countrycodes=vn';
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'User-Agent': 'FoodOiApp'
      }).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isEmpty) {
          throw Exception('Delivery only available within Vietnam');
        }
        final addressDetails = data[0]['address'];
        final country = addressDetails['country'] ?? '';
        if (country.isEmpty || !['Vietnam', 'Viet Nam'].contains(country)) {
          throw Exception('Delivery only available within Vietnam');
        }
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        // Validate coordinates (Vietnam bounds: lat 8-24, lon 102-109)
        if (lat < 8 || lat > 24 || lon < 102 || lon > 109) {
          throw Exception('Delivery only available within Vietnam');
        }
        // Warn for ambiguous addresses (e.g., province only)
        if (addressDetails['city'] == null &&
            addressDetails['town'] == null &&
            addressDetails['village'] == null) {
          print(
              'DeliveryService - Warning: "$address" may be too broad, consider adding street or city');
        }
        final location = LatLng(lat, lon);
        _geocodeCache[address] = location;
        print(
            'DeliveryService - Coordinates for "$address": ($lat, $lon), country: $country');
        return location;
      }
      throw Exception('Failed to fetch coordinates: ${response.statusCode}');
    } catch (e) {
      print('DeliveryService - Geocoding error for "$address": $e');
      throw e;
    }
  }

  // Calculate delivery fee and time (combined)
  Future<Map<String, dynamic>> calculateDeliveryFeeAndTime(
      LatLng restaurant, LatLng customer) async {
    final distance = await getDistanceFromOSRM(restaurant, customer);

    // Reject distances >150km
    if (distance > 500) {
      throw Exception('Delivery distance exceeds 500km');
    }

    // Calculate fee, rounded to nearest 10,000 VND
    int finalFee;
    if (distance > 50) {
      final scaledFee = 50000 +
          ((distance - 50) * 1000).round(); // 1,000 VND per km above 50km
      final cappedFee = scaledFee > 150000 ? 150000 : scaledFee;
      finalFee = ((cappedFee + 5000) / 10000).round() *
          10000; // Round to nearest 10,000
    } else {
      final rawFee = distance * 5000; // 5,000 VND per km
      final fee = (rawFee / 1000).round() * 1000; // Round to nearest 1,000 VND
      final minFee =
          customer.latitude < 11 ? 15000 : (fee < 10000 ? 10000 : fee);
      finalFee =
          ((minFee + 5000) / 10000).round() * 10000; // Round to nearest 10,000
    }

    // Estimate time
    String time;
    if (distance < 5) {
      time = "16 min";
    } else if (distance < 10) {
      time = "18 min";
    } else if (distance < 20) {
      time = "20 min";
    } else {
      final timeInHours = distance / 30; // 30 km/h average speed
      final timeInMinutes = (timeInHours * 60).round();
      if (timeInMinutes < 60) {
        time = "$timeInMinutes min";
      } else {
        final hours = (timeInMinutes / 60).round();
        time = "$hours hr";
      }
    }

    print(
        'DeliveryService - Calculated fee: $finalFee, time: $time for distance: ${distance.toStringAsFixed(2)}km');
    return {'fee': finalFee, 'time': time};
  }

  // Format number with dots
  String formatNumberWithDots(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  // Update delivery details with cached LatLng
  Future<void> updateDeliveryDetailsWithLatLng(
      String address, LatLng customerLocation) async {
    print('DeliveryService - Updating delivery details for: $address');
    try {
      if (address.isNotEmpty) {
        final results = await calculateDeliveryFeeAndTime(
            defaultRestaurantLocation, customerLocation);
        final fee = results['fee'] as int;
        final time = results['time'] as String;
        _estimatedTime = time;
        _deliveryFee = "${formatNumberWithDots(fee)} VND";
        print(
            'DeliveryService - Updated: Time = $time, Fee = ${formatNumberWithDots(fee)} VND');
      } else {
        _estimatedTime = "N/A";
        _deliveryFee = "N/A";
        print('DeliveryService - Address empty, resetting to N/A');
      }
      notifyListeners();
    } catch (e) {
      _estimatedTime = "N/A";
      _deliveryFee = "N/A";
      print('DeliveryService - Error updating delivery details: $e');
      notifyListeners();
      throw e; // Propagate error to UI
    }
  }

  // Original updateDeliveryDetails
  Future<void> updateDeliveryDetails(String address) async {
    try {
      final customerLocation = await getCoordinatesFromAddress(address);
      await updateDeliveryDetailsWithLatLng(address, customerLocation);
    } catch (e) {
      _estimatedTime = "N/A";
      _deliveryFee = "N/A";
      print('DeliveryService - Error in updateDeliveryDetails: $e');
      notifyListeners();
      throw e; // Propagate error to UI
    }
  }
}
