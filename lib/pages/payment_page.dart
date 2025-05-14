import 'package:flutter/material.dart';
import 'package:foi/components/my_button.dart';
import 'package:foi/pages/delivery_progress_page.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:foi/models/restaurant.dart';
import 'package:provider/provider.dart';
import 'package:foi/payment/vnpay/vnpay_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'vnpay_payment_page.dart';

class PaymentPage extends StatefulWidget {
  final double basePrice;
  final double discountAmount;
  final String? voucherCode;
  final double totalPrice;
  final String selectedPaymentMethod;
  final double deliveryFee;

  const PaymentPage({
    super.key,
    required this.basePrice,
    required this.discountAmount,
    this.voucherCode,
    required this.totalPrice,
    required this.selectedPaymentMethod,
    required this.deliveryFee,
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

  final _vnpayService = VNPayService();

  void userTappedPay() async {
    print(
        'PaymentPage - userTappedPay() called. Payment method: ${widget.selectedPaymentMethod}');

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

    if (widget.selectedPaymentMethod == "Card" &&
        !formKey.currentState!.validate()) {
      print('PaymentPage - Card payment - Form is invalid. Returning.');
      return;
    }

    if (widget.selectedPaymentMethod == "VNPAY") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VNPayPaymentPage(amount: widget.totalPrice),
        ),
      );
      return;
    }

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
              Text("Cart Total: ${restaurant.formatPrice(widget.basePrice)}"),
              Text(
                  "Delivery Fee: ${restaurant.formatPrice(widget.deliveryFee * 1000)}"),
              if (widget.discountAmount > 0) ...[
                Text("Voucher: ${widget.voucherCode ?? ''}"),
                Text(
                  "Discount: -${restaurant.formatPrice(widget.discountAmount)}",
                  style: const TextStyle(color: Colors.green),
                ),
              ],
              Text(
                "Final Total: ${restaurant.formatPrice(widget.totalPrice)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
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
            onPressed: () async {
              print('PaymentPage - Confirmation dialog - Yes button pressed.');
              Navigator.pop(context);

              // Tạo receipt và cập nhật payment status
              final receipt = restaurant.displayCartReceipt();
              restaurant.updatePaymentStatus("Paid");

              // Chuyển đến trang delivery progress với receipt và payment status
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeliveryProgressPage(
                    receipt: receipt,
                    paymentStatus: "Paid",
                  ),
                ),
              );

              // Clear cart sau khi đã chuyển trang
              restaurant.clearCart();
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
    final restaurant = context.read<Restaurant>();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Checkout"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phương thức thanh toán Cash
            if (widget.selectedPaymentMethod == "Cash")
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.money, color: Colors.green, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Cash Payment Selected",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "You will pay with cash upon delivery.",
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Phương thức thanh toán VNPay
            if (widget.selectedPaymentMethod == "VNPAY")
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.qr_code_scanner,
                        size: 100, color: Colors.blue),
                    const SizedBox(height: 12),
                    const Text(
                      "VNPay Payment Selected",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "You will be redirected to the VNPay payment gateway to complete your payment.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Payment Summary Section
            const Text(
              "Payment Summary",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Cart Total:", style: TextStyle(fontSize: 16)),
                Text(
                  restaurant.formatPrice(widget.basePrice),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Delivery Fee:", style: TextStyle(fontSize: 16)),
                Text(
                  restaurant.formatPrice(widget.deliveryFee * 1000),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            if (widget.discountAmount > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Discount (${widget.voucherCode ?? ''}):",
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    "-${restaurant.formatPrice(widget.discountAmount)}",
                    style: const TextStyle(fontSize: 16, color: Colors.green),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Final Total:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  restaurant.formatPrice(widget.totalPrice),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Confirm Order Button
            MyButton(
              text: widget.selectedPaymentMethod == "Cash"
                  ? "Confirm Order"
                  : "Pay now",
              onTap: userTappedPay,
            ),
          ],
        ),
      ),
    );
  }
}
