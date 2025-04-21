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

  String get estimatedTime => _estimatedTime;
  String get deliveryFee => _deliveryFee;

  // Haversine formula for distance (fallback for short distances)
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

  // Get distance via OSRM
  Future<double> getDistanceFromOSRM(LatLng origin, LatLng destination) async {
    // Fallback to Haversine for short distances
    final haversineDistance = calculateHaversineDistance(origin, destination);
    if (haversineDistance < 5) {
      return haversineDistance;
    }

    final url = 'http://router.project-osrm.org/route/v1/driving/'
        '${origin.longitude},${origin.latitude};'
        '${destination.longitude},${destination.latitude}'
        '?overview=false';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 'Ok') {
          final distanceInMeters = data['routes'][0]['distance'];
          print(
              'DeliveryService - OSRM distance: ${(distanceInMeters / 1000).toStringAsFixed(2)}km');
          return distanceInMeters / 1000;
        }
        throw Exception('OSRM returned invalid status: ${data['code']}');
      }
      throw Exception('Failed to fetch distance: ${response.statusCode}');
    } catch (e) {
      print('DeliveryService - OSRM API error: $e');
      return haversineDistance; // Fallback
    }
  }

  // Get coordinates from address
  Future<LatLng> getCoordinatesFromAddress(String address) async {
    final url =
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeQueryComponent(address)}&format=json&limit=1';
    try {
      final response =
          await http.get(Uri.parse(url), headers: {'User-Agent': 'FoodOiApp'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          print('DeliveryService - Coordinates for "$address": ($lat, $lon)');
          return LatLng(lat, lon);
        }
        print('DeliveryService - No coordinates found for "$address"');
      }
      throw Exception('Unable to find coordinates for this address');
    } catch (e) {
      print('DeliveryService - Geocoding error for "$address": $e');
      throw e;
    }
  }

  // Calculate delivery fee
  Future<int> calculateDeliveryFee(LatLng restaurant, LatLng customer) async {
    final distance = await getDistanceFromOSRM(restaurant, customer);
    final rawFee = distance * 5000; // 5.000₫ per km
    final fee = (rawFee / 1000).round() * 1000; // Round to nearest 1.000₫
    // Adjust for Ho Chi Minh or minimum fee
    final finalFee =
        customer.latitude < 11 ? 15000 : (fee < 10000 ? 10000 : fee);
    print(
        'DeliveryService - Calculated fee: $finalFee for distance: ${distance.toStringAsFixed(2)}km');
    return finalFee;
  }

  // Format number with dots
  String formatNumberWithDots(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  // Estimate delivery time
  Future<String> estimateDeliveryTime(
      LatLng restaurant, LatLng customer) async {
    final distance = await getDistanceFromOSRM(restaurant, customer);
    if (distance < 5) return "16 min";
    if (distance < 10) return "18 min";
    if (distance < 20) return "20 min";

    final timeInHours = distance / 30;
    final timeInMinutes = (timeInHours * 60).round();

    if (timeInMinutes < 60) {
      return "$timeInMinutes min";
    } else if (timeInMinutes < 1440) {
      final hours = (timeInMinutes / 60).round();
      return "$hours hr";
    } else {
      final days = (timeInMinutes / 1440).round();
      return "$days day${days > 1 ? 's' : ''}";
    }
  }

  // Update delivery details with cached LatLng
  Future<void> updateDeliveryDetailsWithLatLng(
      String address, LatLng customerLocation) async {
    print('DeliveryService - Updating delivery details for: $address');
    try {
      if (address.isNotEmpty) {
        // Parallelize fee and time calculations
        final results = await Future.wait([
          calculateDeliveryFee(defaultRestaurantLocation, customerLocation),
          estimateDeliveryTime(defaultRestaurantLocation, customerLocation),
        ]);
        final fee = results[0] as int;
        final time = results[1] as String;
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
    }
  }

  // Original updateDeliveryDetails (for compatibility)
  Future<void> updateDeliveryDetails(String address) async {
    try {
      final customerLocation = await getCoordinatesFromAddress(address);
      await updateDeliveryDetailsWithLatLng(address, customerLocation);
    } catch (e) {
      _estimatedTime = "N/A";
      _deliveryFee = "N/A";
      print('DeliveryService - Error in updateDeliveryDetails: $e');
      notifyListeners();
    }
  }
}
