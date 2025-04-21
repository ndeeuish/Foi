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
                        content: Text("Please enter a valid delivery address")),
                  );
                  return;
                }
                setState(() => isLoading = true);
                try {
                  // Geocode address to LatLng
                  final deliveryService = context.read<DeliveryService>();
                  final customerLocation = await deliveryService
                      .getCoordinatesFromAddress(newAddress);
                  // Calculate delivery fee
                  final fee = (await deliveryService.calculateDeliveryFee(
                    deliveryService.defaultRestaurantLocation,
                    customerLocation,
                  ))
                      .toDouble();
                  print(
                      'MyCurrentLocation - Calculated fee: ${context.read<Restaurant>().formatPrice(fee)} for address: $newAddress');
                  // Set delivery fee in Restaurant
                  context.read<Restaurant>().setDeliveryFee(fee);
                  // Update address in Restaurant
                  context.read<Restaurant>().updateDeliveryAddress(newAddress);
                  // Update DeliveryService details with cached LatLng
                  await deliveryService.updateDeliveryDetailsWithLatLng(
                      newAddress, customerLocation);
                  Navigator.pop(context);
                  textController.clear();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error processing address: $e")),
                  );
                } finally {
                  setState(() => isLoading = false);
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
