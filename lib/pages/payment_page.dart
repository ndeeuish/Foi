import 'package:flutter/material.dart';
import 'package:foi/components/my_button.dart';
import 'package:foi/pages/delivery_progress_page.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:foi/models/restaurant.dart';
import 'package:provider/provider.dart';
// import 'package:foi/models/cart_item.dart' hide CartItem; // Uncomment if cart_item.dart exists
import 'package:foi/payment/vnpay/vnpay_service.dart'; // Import VNPayService

class PaymentPage extends StatefulWidget {
  final double totalPrice;
  final String selectedPaymentMethod;

  const PaymentPage({
    super.key,
    required this.totalPrice,
    required this.selectedPaymentMethod,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  final _vnpayService = VNPayService(); // Tạo instance của VNPayService

  void userTappedPay() async {
    print(
        'PaymentPage - userTappedPay() called. Payment method: ${widget.selectedPaymentMethod}');

    // Kiểm tra địa chỉ giao hàng
    final restaurant = context.read<Restaurant>();
    if (restaurant.deliveryAddress.isEmpty ||
        restaurant.deliveryAddress == "Enter your address") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter the delivery address"),
        ),
      );
      return;
    }

    // Kiểm tra form hợp lệ nếu là thanh toán bằng thẻ
    if (widget.selectedPaymentMethod == "Card" &&
        !formKey.currentState!.validate()) {
      print('PaymentPage - Card payment - Form is invalid. Returning.');
      return;
    }

    // Xử lý thanh toán VNPAY
    if (widget.selectedPaymentMethod == "VNPAY") {
      print(
          'PaymentPage - VNPAY selected. Calling VNPay service to get payment URL.');
      final paymentUrl = await _vnpayService.getPaymentUrl(widget.totalPrice);

      if (paymentUrl != null) {
        print('PaymentPage - VNPAY - Payment URL received: $paymentUrl');
        try {
          final Uri uri = Uri.parse(paymentUrl);
          print('PaymentPage - VNPAY - Parsed URI: $uri');
          if (await canLaunchUrl(uri)) {
            print('PaymentPage - VNPAY - URL can be launched. Launching...');
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            print('PaymentPage - VNPAY - URL launched successfully.');
          } else {
            print('PaymentPage - VNPAY - URL cannot be launched.');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Không thể mở URL thanh toán VNPAY")),
            );
          }
        } catch (e) {
          print(
              'PaymentPage - VNPAY - An error occurred while launching URL: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Đã xảy ra lỗi khi mở URL thanh toán")),
          );
        }
      } else {
        print('PaymentPage - VNPAY - Failed to get payment URL from service.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lỗi khi tạo URL thanh toán VNPAY")),
        );
      }
      print('PaymentPage - VNPAY - Finished processing.');
      return;
    }

    // Hiển thị hộp thoại xác nhận
    print(
        'PaymentPage - Payment method is ${widget.selectedPaymentMethod}. Showing confirmation dialog.');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.selectedPaymentMethod == "Cash"
            ? "Confirm Order"
            : "Confirm Payment"),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text("Payment Method: ${widget.selectedPaymentMethod}"),
              Text("Total Price: ${restaurant.formatPrice(widget.totalPrice)}"),
              if (widget.selectedPaymentMethod == "Card") ...[
                Text("Card Number: $cardNumber"),
                Text("Expiry Date: $expiryDate"),
                Text("Card Holder Name: $cardHolderName"),
                Text("CVV: $cvvCode"),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('PaymentPage - Confirmation dialog - Yes button pressed.');
              Navigator.pop(context);
              context.read<Restaurant>().updatePaymentStatus("Paid");
              print('PaymentPage - Payment status updated to: Paid');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DeliveryProgressPage(),
                ),
              );
            },
            child: const Text("Yes"),
          ),
          TextButton(
            onPressed: () {
              print(
                  'PaymentPage - Confirmation dialog - Cancel button pressed.');
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Checkout"),
      ),
      body: Column(
        children: [
          if (widget.selectedPaymentMethod == "Card")
            Column(
              children: [
                CreditCardWidget(
                  cardNumber: cardNumber,
                  expiryDate: expiryDate,
                  cardHolderName: cardHolderName,
                  cvvCode: cvvCode,
                  showBackView: isCvvFocused,
                  onCreditCardWidgetChange: (p0) {},
                ),
                CreditCardForm(
                  cardNumber: cardNumber,
                  expiryDate: expiryDate,
                  cardHolderName: cardHolderName,
                  cvvCode: cvvCode,
                  onCreditCardModelChange: (data) {
                    setState(() {
                      cardNumber = data.cardNumber;
                      expiryDate = data.expiryDate;
                      cardHolderName = data.cardHolderName;
                      cvvCode = data.cvvCode;
                      isCvvFocused = data.isCvvFocused;
                    });
                  },
                  formKey: formKey,
                ),
              ],
            ),
          if (widget.selectedPaymentMethod == "VNPAY")
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(Icons.qr_code_scanner, size: 100, color: Colors.blue),
                  SizedBox(height: 10),
                  Text("You will be redirected to the VNPAY payment gateway"),
                ],
              ),
            ),
          const Spacer(),
          MyButton(
            text: widget.selectedPaymentMethod == "Cash"
                ? "Confirm Order"
                : "Pay now",
            onTap: userTappedPay,
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }
}
