import 'package:flutter/material.dart';
import 'package:foi/models/restaurant.dart';
import 'package:provider/provider.dart';
// import 'package:foi/models/cart_item.dart' hide CartItem; // Uncomment if needed

class MyReceipt extends StatelessWidget {
  final String receipt;
  final String paymentStatus;

  const MyReceipt({
    super.key,
    required this.receipt,
    required this.paymentStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Consumer<Restaurant>(
        builder: (context, restaurant, child) {
          final totalItems = restaurant.getTotalItemCount();
          final totalPrice = restaurant.getTotalPrice();
          final deliveryAddress = restaurant.deliveryAddress;

          print('MyReceipt - Displaying receipt:');
          print('Total Items: $totalItems');
          print('Total Price: ${restaurant.formatPrice(totalPrice)}');
          print('Delivery Address: $deliveryAddress');

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Order Receipt",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Items: $totalItems',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Total Price: ${restaurant.formatPrice(totalPrice)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Delivery Address:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(deliveryAddress),
                      const SizedBox(height: 16),
                      const Text(
                        'Receipt Details:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        receipt,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
