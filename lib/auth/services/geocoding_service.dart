import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodingService {
  final Map<String, LatLng> _geocodeCache = {};

  Future<LatLng> getCoordinatesFromAddress(String address,
      {int retries = 2}) async {
    String normalizedAddress = address.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (!normalizedAddress.toLowerCase().contains('vietnam') &&
        !normalizedAddress.toLowerCase().contains('viet nam')) {
      normalizedAddress += ', Vietnam';
    }

    if (_geocodeCache.containsKey(normalizedAddress)) {
      print(
          'GeocodingService - Using cached coordinates for "$normalizedAddress": ${_geocodeCache[normalizedAddress]}');
      return _geocodeCache[normalizedAddress]!;
    }

    final url =
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeQueryComponent(normalizedAddress)}&format=json&limit=1&addressdetails=1&countrycodes=vn';
    for (int attempt = 1; attempt <= retries; attempt++) {
      try {
        final response = await http.get(Uri.parse(url), headers: {
          'User-Agent': 'FoodOiApp'
        }).timeout(const Duration(seconds: 10));
        print(
            'GeocodingService - Nominatim response for "$normalizedAddress": status=${response.statusCode}, attempt=$attempt');

        if (response.statusCode == 429) {
          if (attempt < retries) {
            await Future.delayed(Duration(seconds: attempt * 2));
            continue;
          }
          throw Exception('Rate limit exceeded. Please try again later.');
        }
        if (response.statusCode != 200) {
          throw Exception(
              'Failed to fetch coordinates: HTTP ${response.statusCode}');
        }

        final data = jsonDecode(response.body);
        if (data.isEmpty) {
          throw Exception(
              'No results found for "$normalizedAddress". Please provide a more specific address.');
        }
        final addressDetails = data[0]['address'];
        print(
            'GeocodingService - Address details for "$normalizedAddress": $addressDetails');
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        if (lat < 8 || lat > 24 || lon < 102 || lon > 109) {
          throw Exception('Coordinates outside Vietnam bounds: ($lat, $lon)');
        }
        if (addressDetails['city'] == null &&
            addressDetails['town'] == null &&
            addressDetails['village'] == null) {
          print(
              'GeocodingService - Warning: "$normalizedAddress" may be too broad, consider adding street or city');
        }
        final location = LatLng(lat, lon);
        _geocodeCache[normalizedAddress] = location;
        print(
            'GeocodingService - Coordinates for "$normalizedAddress": ($lat, $lon)');
        return location;
      } catch (e) {
        print(
            'GeocodingService - Geocoding error for "$normalizedAddress": $e');
        if (attempt == retries) {
          throw Exception('Failed to geocode address: $e');
        }
      }
    }
    throw Exception('Failed to geocode address after $retries attempts');
  }

  Future<LatLng> getCoordinatesWithFallback(String address) async {
    try {
      print('GeocodingService - Attempting to geocode: $address');
      return await getCoordinatesFromAddress(address);
    } catch (e) {
      print('GeocodingService - Geocoding error for "$address": $e');
      final refinedAddress = '$address, Hanoi, Vietnam';
      print(
          'GeocodingService - Retrying with refined address: $refinedAddress');
      try {
        return await getCoordinatesFromAddress(refinedAddress);
      } catch (retryError) {
        print(
            'GeocodingService - Retry failed for "$refinedAddress": $retryError');
        throw Exception(
            'Please enter a more specific address (e.g., "$address, Hanoi, Vietnam")');
      }
    }
  }
}
