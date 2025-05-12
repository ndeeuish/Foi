import 'package:http/http.dart' as http;
import 'dart:convert';

class VNPayService {
  static const String _functionUrl = 'https://us-central1-fooddelivery-c4d4d.cloudfunctions.net/createVnpayPayment';
  
  Future<String?> getPaymentUrl(double amount) async {
    try {
      final url = Uri.parse(_functionUrl);
      final response = await http.get(
  Uri.parse('$_functionUrl?amount=$amount&orderInfo=TestOrder'),
);
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['paymentUrl'];
      } else {
        print('Failed to get payment URL: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error getting payment URL: $e');
      return null;
    }
  }

  // Hàm để kiểm tra trạng thái thanh toán từ Firestore
  // ...
}