import 'package:flutter/material.dart';
import 'package:foi/components/my_button.dart';
import 'package:foi/models/food.dart';
import 'package:foi/models/restaurant.dart';
import 'package:foi/pages/cart_page.dart';
import 'package:provider/provider.dart';

class FoodPage extends StatefulWidget {
  final Food food;
  final Map<Addon, bool> selectedAddons = {};

  FoodPage({super.key, required this.food}) {
    // Initialize selected addons as false
    for (Addon addon in food.availableAddons) {
      selectedAddons[addon] = false;
    }
  }

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  // Method to add to cart
  void addToCart(Food food, Map<Addon, bool> selectedAddons) {
    // Close the food page to return to menu
    Navigator.pop(context);

    // Format selected addons
    List<Addon> currentlySelectedAddons = [];
    for (Addon addon in widget.food.availableAddons) {
      if (widget.selectedAddons[addon] == true) {
        currentlySelectedAddons.add(addon);
      }
    }

    // Add to cart
    context.read<Restaurant>().addToCart(food, currentlySelectedAddons);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main interface
        Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Food image
                const SizedBox(height: 50),
                Image.asset(widget.food.imagePath),

                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Food name
                      Text(
                        widget.food.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),

                      // Food price (formatted as 70.000₫)
                      Consumer<Restaurant>(
                        builder: (context, restaurant, child) => Text(
                          restaurant.formatPrice(widget.food.price),
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Food description
                      Text(widget.food.description),

                      const SizedBox(height: 10),

                      Divider(color: Theme.of(context).colorScheme.secondary),

                      const SizedBox(height: 10),

                      // Addon section
                      Text(
                        "Add-on",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: widget.food.availableAddons.length,
                          itemBuilder: (context, index) {
                            // Get individual addon
                            Addon addon = widget.food.availableAddons[index];

                            // Display checkbox for addon
                            return Consumer<Restaurant>(
                              builder: (context, restaurant, child) =>
                                  CheckboxListTile(
                                title: Text(addon.name),
                                subtitle: Text(
                                  restaurant.formatPrice(addon
                                      .price), // Format addon price, e.g., 23.000₫
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                value: widget.selectedAddons[addon],
                                onChanged: (bool? value) {
                                  setState(() {
                                    widget.selectedAddons[addon] = value!;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Action buttons
                Row(
                  children: [
                    // Add to cart
                    Expanded(
                      child: MyButton(
                        onTap: () =>
                            addToCart(widget.food, widget.selectedAddons),
                        text: "Add to cart",
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Buy now
                    Expanded(
                      child: MyButton(
                        onTap: () {
                          addToCart(widget.food, widget.selectedAddons);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CartPage(),
                            ),
                          );
                        },
                        text: "Buy now",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),
              ],
            ),
          ),
        ),

        // Back button
        SafeArea(
          child: Opacity(
            opacity: 0.5,
            child: Container(
              margin: const EdgeInsets.only(left: 25),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
