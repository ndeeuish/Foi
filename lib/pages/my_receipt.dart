import 'package:flutter/material.dart';
import 'package:foi/auth/services/delivery_service.dart';
import 'package:foi/models/restaurant.dart';
import 'package:provider/provider.dart';

class MyReceipt extends StatelessWidget {
  const MyReceipt({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25, top: 50),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Thank you for your order!"),
            const SizedBox(height: 25),
            Container(
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).colorScheme.secondary),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(20),
              child: Consumer<Restaurant>(
                builder: (context, restaurant, child) => Text(
                  restaurant.displayCartReceipt(),
                  style: const TextStyle(fontFamily: 'Roboto'),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Consumer<DeliveryService>(
              builder: (context, deliveryService, child) => Text(
                "Estimated delivery time is ${deliveryService.estimatedTime}",
                style: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
