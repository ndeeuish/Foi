import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../payment/vnpay/vnpay_service.dart';

class VNPayPaymentPage extends StatefulWidget {
  final double amount;

  VNPayPaymentPage({required this.amount});

  @override
  _VNPayPaymentPageState createState() => _VNPayPaymentPageState();
}

class _VNPayPaymentPageState extends State<VNPayPaymentPage> {
  String? paymentUrl;
  final VNPayService _vnpayService = VNPayService();

  @override
  void initState() {
    super.initState();
    _loadPaymentUrl();
  }

  Future<void> _loadPaymentUrl() async {
    paymentUrl = await _vnpayService.getPaymentUrl(widget.amount);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('VNPay Payment')),
      body: paymentUrl != null
          ? WebViewWidget(
              controller: WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..setNavigationDelegate(
                  NavigationDelegate(
                    onNavigationRequest: (NavigationRequest request) {
                      if (request.url.contains('vnp_ResponseCode')) {
                        final uri = Uri.parse(request.url);
                        final orderId = uri.queryParameters['vnp_TxnRef'];

                        // Gọi Firestore để lấy trạng thái đơn hàng (paymentStatus)
                        FirebaseFirestore.instance
                            .collection('orders')
                            .doc(orderId)
                            .get()
                            .then((doc) {
                          final status = doc['paymentStatus'];
                          // Hiển thị dialog hoặc navigate tới trang kết quả
                          showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                    title: Text("Kết quả thanh toán"),
                                    content: Text(status == "success"
                                        ? "Thanh toán thành công"
                                        : "Thanh toán thất bại"),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text("OK"))
                                    ],
                                  ));
                        });

                        return NavigationDecision.prevent;
                      }

                      return NavigationDecision.navigate;
                    },
                  ),
                )
                ..loadRequest(Uri.parse(paymentUrl!)),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
