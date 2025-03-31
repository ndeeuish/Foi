import 'package:flutter/material.dart';
import 'package:foi/components/my_button.dart';
import 'package:foi/pages/delivery_progress_page.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class PaymentPage extends StatefulWidget {
  final double totalPrice;

  const PaymentPage({super.key, required this.totalPrice, required String paymentMethod});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String selectedPaymentMethod = "Card";
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  void userTappedPay() {
    if (selectedPaymentMethod == "Card" && !formKey.currentState!.validate()) {
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(selectedPaymentMethod == "Cash" ? "Confirm Order" : "Confirm Payment"),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text("Payment Method: $selectedPaymentMethod"),
              Text("Total Price: \$${widget.totalPrice.toStringAsFixed(2)}"),
              if (selectedPaymentMethod == "Card") ...[
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
          DropdownButton<String>(
            value: selectedPaymentMethod,
            onChanged: (String? newValue) {
              setState(() {
                selectedPaymentMethod = newValue!;
              });
            },
            items: <String>["Card", "Cash", "E-Wallet"]
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          if (selectedPaymentMethod == "Card") ...[
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
          const Spacer(),
          MyButton(
            text: selectedPaymentMethod == "Cash" ? "Confirm Order" : "Pay now", 
            onTap: userTappedPay,
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }
}
