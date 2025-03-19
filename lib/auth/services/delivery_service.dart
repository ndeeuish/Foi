import 'dart:convert';
import 'package:http/http.dart' as http;

class DeliveryService {
  static const String googleApiKey = 'AIzaSyBcszJ5p7_1N1otMH5HG1wVizM-73m8RIg';
  // Vị trí quán ăn
  static const String restaurantLocation = "123 Restaurant Street, City";

  static Future<String> calculateDeliveryTime(String destination) async {
    const String origin = restaurantLocation;
    final String url =
        'https://maps.googleapis.com/maps/api/distancematrix/json?origins=$origin&destinations=$destination&key=$googleApiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          return data['rows'][0]['elements'][0]['duration']['text'];
        } else {
          return "Unable to calculate";
        }
      } else {
        throw Exception('Failed to fetch distance matrix');
      }
    } catch (e) {
      print("Error calculating delivery time: $e");
      return "Error calculating time";
    }
  }
}
