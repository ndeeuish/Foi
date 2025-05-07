import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import '../payment/stripe/stripe_service.dart';
import '../models/stripe_payment.dart';

class StripePaymentPage extends StatefulWidget {
  final double amount;

  const StripePaymentPage({Key? key, required this.amount}) : super(key: key);

  @override
  State<StripePaymentPage> createState() => _StripePaymentPageState();
}

class _StripePaymentPageState extends State<StripePaymentPage> {
  final StripeService _stripeService = StripeService();
  bool _isLoading = false;
  bool _isCreatingIntent = false;
  String? _errorMessage;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    stripe.Stripe.publishableKey = StripeService.publishableKey;
  }

  Future<void> _handlePayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create payment intent
      setState(() {
        _isCreatingIntent = true;
      });
      final paymentIntent = await _stripeService.createPaymentIntent(widget.amount);
      setState(() {
        _isCreatingIntent = false;
      });

      // Confirm payment with client secret
      await stripe.Stripe.instance.confirmPayment(
        paymentIntentClientSecret: paymentIntent['clientSecret'],
        data: const stripe.PaymentMethodParams.card(
          paymentMethodData: stripe.PaymentMethodData(),
        ),
      );

      // Get payment status
      final payment = await _stripeService.getPaymentStatus(paymentIntent['paymentIntentId']);

      if (payment.status == 'succeeded') {
        // Payment successful
        Navigator.pop(context, payment);
      } else {
        setState(() {
          _errorMessage = 'Payment failed. Please try again.';
        });
      }
    } on stripe.StripeException catch (e) {
      setState(() {
        _errorMessage = e.error.localizedMessage;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
        _isCreatingIntent = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isLoading) {
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Stripe Payment'),
          leading: _isLoading
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Amount: ${widget.amount.toStringAsFixed(2)} VND',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            const Text('Enter your card details below:'),
                            const SizedBox(height: 16),
                            stripe.CardFormField(
                              style: stripe.CardFormStyle(
                                backgroundColor: Colors.white,
                                textColor: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handlePayment,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Pay Now'),
                    ),
                  ],
                ),
              ),
            ),
            if (_isCreatingIntent)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 