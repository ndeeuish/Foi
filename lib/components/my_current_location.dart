import 'package:flutter/material.dart';
import 'package:foi/auth/services/delivery_service.dart';
import 'package:foi/models/restaurant.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';

class MyCurrentLocation extends StatelessWidget {
  MyCurrentLocation({super.key});

  final TextEditingController textController = TextEditingController();

  // Show dialog to enter delivery address
  void openLocationSearchBox(BuildContext context) {
    bool isLoading = false;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Your location"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: const InputDecoration(hintText: "Enter address.."),
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
                // Validate address
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
                  // Geocode address to LatLng
                  final deliveryService = context.read<DeliveryService>();
                  final restaurant = context.read<Restaurant>();
                  final customerLocation = await deliveryService
                      .getCoordinatesFromAddress(newAddress);
                  // Calculate fee and time
                  final results =
                      await deliveryService.calculateDeliveryFeeAndTime(
                    deliveryService.defaultRestaurantLocation,
                    customerLocation,
                  );
                  final fee = (results['fee'] as int).toDouble();
                  final time = results['time'] as String;
                  // Update Restaurant
                  restaurant.setDeliveryFee(fee);
                  restaurant.setEstimatedTime(time);
                  restaurant.updateDeliveryAddress(newAddress);
                  // Update DeliveryService
                  await deliveryService.updateDeliveryDetailsWithLatLng(
                      newAddress, customerLocation);
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
            "Deliver now",
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
