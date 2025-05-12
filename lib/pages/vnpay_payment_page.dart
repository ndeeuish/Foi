import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:foi/pages/delivery_progress_page.dart';
import 'dart:convert';

import '../models/restaurant.dart';

class VNPayPaymentPage extends StatefulWidget {
  final double amount;

  const VNPayPaymentPage({super.key, required this.amount});

  @override
  State<VNPayPaymentPage> createState() => _VNPayPaymentPageState();
}

class _VNPayPaymentPageState extends State<VNPayPaymentPage> {
  String? txnRef;
  bool paymentLaunched = false;

  @override
  void initState() {
    super.initState();
    _startPayment();
  }

  Future<void> _startPayment() async {
    print('VNPayPaymentPage - Starting payment process...');
    try {
      final response = await http.get(
        Uri.parse(
            'https://us-central1-fooddelivery-c4d4d.cloudfunctions.net/createVnpayPayment?amount=${widget.amount}&orderInfo=TestOrder'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print('API Response: $data');

        final paymentUrl = data['paymentUrl'];
        txnRef = data['txnRef']; // Đảm bảo API trả về txnRef

        if (paymentUrl != null) {
          final uri = Uri.parse(paymentUrl);
          if (await canLaunchUrl(uri)) {
            print('Launching VNPay URL: $uri');
            await launchUrl(uri, mode: LaunchMode.externalApplication);

            // Sau khi quay lại app, hiển thị nút kiểm tra
            setState(() {
              paymentLaunched = true;
            });
          } else {
            _showMessage("Không thể mở URL thanh toán VNPAY");
          }
        } else {
          _showMessage("Không nhận được URL thanh toán VNPAY");
        }
      } else {
        _showMessage("Lỗi khi tạo URL thanh toán VNPay");
      }
    } catch (e) {
      print('Error: $e');
      _showMessage("Đã xảy ra lỗi khi tạo URL thanh toán");
    }
  }

  Future<void> _checkPaymentStatus() async {
    if (txnRef == null) {
      _showMessage("Không tìm thấy mã giao dịch. Vui lòng thử lại.");
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('orders')
          .doc(txnRef)
          .get();

      if (doc.exists) {
        final data = doc.data();
        final status = data?['paymentStatus'];
        if (status == 'success') {
          // Lấy dữ liệu từ giỏ hàng
          final restaurant = context.read<Restaurant>();
          final receipt = restaurant.displayCartReceipt();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DeliveryProgressPage(
                receipt: receipt, // Truyền dữ liệu từ giỏ hàng
                paymentStatus: "Paid",
              ),
            ),
          );
        } else {
          _showMessage("Thanh toán thất bại. Vui lòng thử lại.");
        }
      } else {
        _showMessage("Không tìm thấy giao dịch.");
      }
    } catch (e) {
      print("Check payment error: $e");
      _showMessage("Đã xảy ra lỗi khi kiểm tra trạng thái thanh toán");
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thanh toán VNPay")),
      body: Center(
        child: paymentLaunched
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Sau khi hoàn tất thanh toán, nhấn nút dưới đây để kiểm tra trạng thái.",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _checkPaymentStatus,
                    child: const Text("Kiểm tra thanh toán"),
                  ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
