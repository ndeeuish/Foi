import 'package:flutter/material.dart';
import 'package:foi/components/my_button.dart';
import 'package:foi/pages/delivery_progress_page.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:foi/models/restaurant.dart';
import 'package:provider/provider.dart';
// import 'package:foi/models/cart_item.dart' hide CartItem; // Uncomment if cart_item.dart exists

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

  // Handle pay/confirm order tap
  void userTappedPay() async {
    // Check if delivery address is valid
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

    // Validate card details for Card payment
    if (widget.selectedPaymentMethod == "Card" &&
        !formKey.currentState!.validate()) {
      return;
    }

    // Handle VNPAY payment
    if (widget.selectedPaymentMethod == "VNPAY") {
      const sandboxUrl = 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html';
      if (await canLaunchUrl(Uri.parse(sandboxUrl))) {
        await launchUrl(
          Uri.parse(sandboxUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cannot open VNPAY")),
        );
      }
      return;
    }

    // Show confirmation dialog
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
              Text(
                  "Total Price: ${restaurant.formatPrice(widget.totalPrice)}"), // Use VND formatting
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
            onPressed: () => Navigator.pop(context),
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
