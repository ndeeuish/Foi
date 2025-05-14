import 'package:http/http.dart' as http;
import 'dart:convert';

class VNPayService {
  static const String _functionUrl = 'https://createvnpaypayment-fi5yhlbyqq-uc.a.run.app';

  Future<String?> getPaymentUrl(double amount) async {
    try {
      final url = Uri.parse(_functionUrl);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
        }),
      );

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