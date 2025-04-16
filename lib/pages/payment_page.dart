import 'package:flutter/material.dart';
import 'package:foi/components/my_button.dart';
import 'package:foi/pages/delivery_progress_page.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:url_launcher/url_launcher.dart';
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

  void userTappedPay() async {
    if (widget.selectedPaymentMethod == "Card" &&
        !formKey.currentState!.validate()) {
      return;
    }

    if (widget.selectedPaymentMethod == "VNPAY") {
      const sandboxUrl = 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html'; 
      if (await canLaunchUrl(Uri.parse(sandboxUrl))) {
        await launchUrl(Uri.parse(sandboxUrl), mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Không thể mở VNPAY")),
        );
      }
      return; 
    }

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
              Text("Total Price: \$${widget.totalPrice.toStringAsFixed(2)}"),
              if (widget.selectedPaymentMethod == "Card") ...[
                Text("Card Number: $cardNumber"),
                Text("Expiry Date: $expiryDate"),
                Text("Card Holder name: $cardHolderName"),
                Text("CVV: $cvvCode"),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeliveryProgressPage(),
                ),
              );
            },
            child: Text("Yes"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
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
                  Text("Bạn sẽ được chuyển hướng đến cổng thanh toán VNPAY"),
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
