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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(20.0),
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
                  "Order Summary",
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Payment Status',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        paymentStatus,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: paymentStatus.toLowerCase() == 'paid'
                              ? Colors.green[700]
                              : Colors.orange[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Order Details',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        receipt,
                        style: textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Roboto',
                          fontSize: 18,
                          height: 1.3,
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
