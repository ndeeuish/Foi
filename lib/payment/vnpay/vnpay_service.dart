import 'package:http/http.dart' as http;
import 'dart:convert';

class VNPayService {
  Future<String?> getPaymentUrl(double amount) async {
    final url = Uri.parse('https://createvnpaypayment-fi5yhlbyqq-uc.a.run.app');
    final response = await http.post(
      url,
      body: {'amount': amount.toString()},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['paymentUrl'];
    } else {
      print('Failed to get payment URL: ${response.statusCode}');
      return null;
    }
  }

  // Hàm để kiểm tra trạng thái thanh toán từ Firestore
  // ...
}