import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import '../../models/stripe_payment.dart';

class StripeService {
  static const String publishableKey = 'pk_test_51RLzzs2KB6w1OIx4ibZj4SKcr5zlc7NGBtxTe0jf2cN13QQEzXXc8ziO7zHA4nhMxSfQfTfx3PLxeUP5YYvr91jc007E7v2SUi';
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<Map<String, dynamic>> createPaymentIntent(double amount) async {
    try {
      final callable = _functions.httpsCallable('createStripePayment');
      final result = await callable.call({
        'amount': amount,
      });
      
      return result.data;
    } catch (e) {
      throw Exception('Error creating payment intent: $e');
    }
  }

  Future<StripePayment> confirmPayment(String paymentIntentId, String paymentMethodId) async {
    try {
      final url = Uri.parse('https://api.stripe.com/v1/payment_intents/$paymentIntentId/confirm');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $publishableKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'payment_method': paymentMethodId,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return StripePayment(
          paymentIntentId: data['id'],
          amount: data['amount'] / 100, // Convert from cents
          status: data['status'],
          cardLast4: data['payment_method_details']?['card']?['last4'],
          cardBrand: data['payment_method_details']?['card']?['brand'],
        );
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error']?['message'] ?? 'Failed to confirm payment');
      }
    } catch (e) {
      throw Exception('Error confirming payment: $e');
    }
  }

  Future<StripePayment> getPaymentStatus(String paymentIntentId) async {
    try {
      final url = Uri.parse('https://api.stripe.com/v1/payment_intents/$paymentIntentId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $publishableKey',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return StripePayment(
          paymentIntentId: data['id'],
          amount: data['amount'] / 100, // Convert from cents
          status: data['status'],
          cardLast4: data['payment_method_details']?['card']?['last4'],
          cardBrand: data['payment_method_details']?['card']?['brand'],
        );
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error']?['message'] ?? 'Failed to get payment status');
      }
    } catch (e) {
      throw Exception('Error getting payment status: $e');
    }
  }
} 