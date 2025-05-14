import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'geocoding_service.dart';
import 'distance_service.dart';

class DeliveryService with ChangeNotifier {
  final LatLng defaultRestaurantLocation =
      const LatLng(21.0045, 105.8428); // Hanoi
  String _estimatedTime = "N/A";
  String _deliveryFee = "N/A";
  LatLng? _customerLocation;
  final GeocodingService _geocodingService;
  final DistanceService _distanceService;

  DeliveryService()
      : _geocodingService = GeocodingService(),
        _distanceService = DistanceService();

  String get estimatedTime => _estimatedTime;
  String get deliveryFee => _deliveryFee;
  LatLng? get customerLocation => _customerLocation;

  Future<Map<String, dynamic>> calculateDeliveryFeeAndTime(
      LatLng restaurant, LatLng customer) async {
    final distance =
        await _distanceService.getDistanceFromOSRM(restaurant, customer);

    if (distance > 500) {
      throw Exception('Delivery distance exceeds 500km');
    }

    int finalFee;
    if (distance > 50) {
      final scaledFee = 50000 + ((distance - 50) * 1000).round();
      final cappedFee = scaledFee > 150000 ? 150000 : scaledFee;
      finalFee = ((cappedFee + 5000) / 10000).round() * 10000;
    } else {
      final rawFee = distance * 5000;
      final fee = (rawFee / 1000).round() * 1000;
      final minFee =
          customer.latitude < 11 ? 15000 : (fee < 10000 ? 10000 : fee);
      finalFee = ((minFee + 5000) / 10000).round() * 10000;
    }

    String time;
    if (distance < 5) {
      time = "16 min";
    } else if (distance < 10) {
      time = "18 min";
    } else if (distance < 20) {
      time = "20 min";
    } else {
      final timeInHours = distance / 30;
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

  String formatNumberWithDots(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  Future<void> updateDeliveryDetailsWithLatLng(
      String address, LatLng customerLocation) async {
    print('DeliveryService - Updating delivery details for: $address');
    try {
      if (address.isNotEmpty) {
        _customerLocation = customerLocation;
        final results = await calculateDeliveryFeeAndTime(
            defaultRestaurantLocation, customerLocation);
        final fee = results['fee'] as int;
        final time = results['time'] as String;
        _estimatedTime = time;
        _deliveryFee = "${formatNumberWithDots(fee)} VND";
        print(
            'DeliveryService - Updated: Time = $time, Fee = ${formatNumberWithDots(fee)} VND');
      } else {
        _customerLocation = null;
        _estimatedTime = "N/A";
        _deliveryFee = "N/A";
        print('DeliveryService - Address empty, resetting to N/A');
      }
      notifyListeners();
    } catch (e) {
      _customerLocation = null;
      _estimatedTime = "N/A";
      _deliveryFee = "N/A";
      print('DeliveryService - Error updating delivery details: $e');
      notifyListeners();
      throw e;
    }
  }

  Future<void> updateDeliveryDetails(String address) async {
    try {
      final customerLocation =
          await _geocodingService.getCoordinatesWithFallback(address);
      await updateDeliveryDetailsWithLatLng(address, customerLocation);
    } catch (e) {
      _customerLocation = null;
      _estimatedTime = "N/A";
      _deliveryFee = "N/A";
      print('DeliveryService - Error in updateDeliveryDetails: $e');
      notifyListeners();
      throw e;
    }
  }

  Future<double> fetchDistance(String address) async {
    return await _distanceService.fetchDistance(
        address, defaultRestaurantLocation, _geocodingService);
  }
}
