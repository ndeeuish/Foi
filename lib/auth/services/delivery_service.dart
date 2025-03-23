import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

class DeliveryService with ChangeNotifier {
  final LatLng defaultRestaurantLocation = const LatLng(21.0045, 105.8428);
  String _estimatedTime = "N/A";
  String _deliveryFee = "N/A";

  String get estimatedTime => _estimatedTime;
  String get deliveryFee => _deliveryFee;

  double calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371;
    final double dLat = _degreesToRadians(point2.latitude - point1.latitude);
    final double dLon = _degreesToRadians(point2.longitude - point1.longitude);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(point1.latitude)) *
            cos(_degreesToRadians(point2.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  int calculateDeliveryFee(LatLng restaurant, LatLng customer) {
    final distance = calculateDistance(restaurant, customer);
    final rawFee = distance * 5000;
    return (rawFee / 1000).round() * 1000;
  }

  String estimateDeliveryTime(LatLng restaurant, LatLng customer) {
    final distance = calculateDistance(restaurant, customer);
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

  Future<LatLng> getCoordinatesFromAddress(String address) async {
    final url =
        'https://nominatim.openstreetmap.org/search?q=$address&format=json&limit=1';
    try {
      final response =
          await http.get(Uri.parse(url), headers: {'User-Agent': 'FoodOiApp'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          print('Coordinates for "$address": ($lat, $lon)');
          return LatLng(lat, lon);
        }
        print('No coordinates found for "$address"');
      }
      throw Exception('Unable to find coordinates for this address');
    } catch (e) {
      print('Geocoding error for "$address": $e');
      throw e;
    }
  }

  Future<void> updateDeliveryDetails(String address) async {
    print('Updating delivery details for: $address');
    try {
      if (address.isNotEmpty) {
        final customerLocation = await getCoordinatesFromAddress(address);
        final time =
            estimateDeliveryTime(defaultRestaurantLocation, customerLocation);
        final fee =
            calculateDeliveryFee(defaultRestaurantLocation, customerLocation);
        _estimatedTime = time;
        _deliveryFee = "$fee VND";
        print('Updated: Time = $time, Fee = $fee VND');
      } else {
        _estimatedTime = "N/A";
        _deliveryFee = "N/A";
        print('Address empty, resetting to N/A');
      }
      notifyListeners();
    } catch (e) {
      _estimatedTime = "N/A";
      _deliveryFee = "N/A";
      print('Error updating delivery details: $e');
      notifyListeners();
    }
  }
}
