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
              restaurant.updatePaymentStatus("Pending");
              final status = restaurant.paymentStatus;
              final receipt = restaurant.displayCartReceipt();         

              // Chuyển đến trang delivery progress với receipt và payment status
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeliveryProgressPage(
                    receipt: receipt,
                    paymentStatus: status,
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        style:
                            const TextStyle(fontSize: 16, color: Colors.green),
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      restaurant.formatPrice(widget.totalPrice),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
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