import 'package:flutter/material.dart';
import 'package:foi/auth/services/delivery_service.dart';
import 'package:foi/models/restaurant.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';

class MyCurrentLocation extends StatelessWidget {
  MyCurrentLocation({super.key});

  final TextEditingController textController = TextEditingController();

  Future<void> openLocationSearchBox(BuildContext context) async {
    bool isLoading = false;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Delivery Address"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: const InputDecoration(hintText: "Enter address..."),
                style: const TextStyle(fontFamily: 'Roboto'),
              ),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
          actions: [
            MaterialButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            MaterialButton(
              onPressed: () async {
                String newAddress = textController.text.trim();
                if (newAddress.isEmpty || newAddress == "Enter your address") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Please enter a valid address")),
                  );
                  return;
                }
                if (context.mounted) {
                  setState(() => isLoading = true);
                  print('MyCurrentLocation - Showing loading');
                }
                try {
                  final deliveryService = context.read<DeliveryService>();
                  final restaurant = context.read<Restaurant>();
                  await deliveryService.updateDeliveryDetails(newAddress);
                  final fee = double.parse(deliveryService.deliveryFee
                          .replaceAll(RegExp(r'[^\d]'), '')) /
                      1000;
                  final time = deliveryService.estimatedTime;
                  restaurant.setDeliveryFee(fee);
                  restaurant.setEstimatedTime(time);
                  restaurant.updateDeliveryAddress(newAddress);
                  print(
                      'MyCurrentLocation - Updated address: $newAddress, fee: ${restaurant.formatPrice(fee)}, time: $time');
                  if (context.mounted) {
                    Navigator.pop(context);
                    textController.clear();
                    print('MyCurrentLocation - Closing dialog');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                } finally {
                  if (context.mounted) {
                    setState(() => isLoading = false);
                    print('MyCurrentLocation - Hiding loading');
                  }
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Deliver Now",
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          GestureDetector(
            onTap: () => openLocationSearchBox(context),
            child: Row(
              children: [
                Consumer<Restaurant>(
                  builder: (context, restaurant, child) => Text(
                    restaurant.deliveryAddress.isEmpty
                        ? "Enter your address"
                        : restaurant.deliveryAddress,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
