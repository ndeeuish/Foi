import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

class DeliveryService with ChangeNotifier {
  final LatLng defaultRestaurantLocation = const LatLng(21.0045, 105.8428);
  String _estimatedTime = "N/A";
  String _deliveryFee = "N/A";

  String get estimatedTime => _estimatedTime;
  String get deliveryFee => _deliveryFee;

  // Lấy khoảng cách
  Future<double> getDistanceFromOSRM(LatLng origin, LatLng destination) async {
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
          return distanceInMeters / 1000;
        }
        throw Exception('OSRM returned invalid status: ${data['code']}');
      }
      throw Exception('Failed to fetch distance: ${response.statusCode}');
    } catch (e) {
      print('OSRM API error: $e');
      throw e;
    }
  }

  // Lấy tọa độ
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

  // Tính phí giao hàng
  Future<int> calculateDeliveryFee(LatLng restaurant, LatLng customer) async {
    final distance = await getDistanceFromOSRM(restaurant, customer);
    final rawFee = distance * 5000;
    return (rawFee / 1000).round() * 1000;
  }

  // Format số với dấu chấm
  String formatNumberWithDots(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

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

  // Cập nhật thông tin giao hàng
  Future<void> updateDeliveryDetails(String address) async {
    print('Updating delivery details for: $address');
    try {
      if (address.isNotEmpty) {
        final customerLocation = await getCoordinatesFromAddress(address);
        final time = await estimateDeliveryTime(
            defaultRestaurantLocation, customerLocation);
        final fee = await calculateDeliveryFee(
            defaultRestaurantLocation, customerLocation);
        _estimatedTime = time;
        _deliveryFee = "${formatNumberWithDots(fee)} VND";
        print('Updated: Time = $time, Fee = ${formatNumberWithDots(fee)} VND');
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
