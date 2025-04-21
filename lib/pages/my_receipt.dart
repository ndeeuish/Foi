import 'package:flutter/material.dart';
import 'package:foi/models/restaurant.dart';
import 'package:provider/provider.dart';
// import 'package:foi/models/cart_item.dart' hide CartItem; // Uncomment if needed

class MyReceipt extends StatelessWidget {
  const MyReceipt({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Consumer<Restaurant>(
        builder: (context, restaurant, child) {
          final receipt = restaurant.displayCartReceipt();
          print(
              'MyReceipt - Displaying receipt with Total: ${restaurant.formatPrice(restaurant.getTotalPrice())}');
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
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  child: Text(
                    receipt,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      height: 1.5,
                    ),
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
