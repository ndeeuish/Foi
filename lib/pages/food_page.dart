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
    return Scaffold(
      body: Stack(
        children: [
          // Food image at the top
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: Image.asset(
                widget.food.imagePath,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Back button on top of the image
          Positioned(
            top: 60, // Đẩy nút quay lại xuống thêm
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.5),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                color: Colors.white,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Content below the image
          Positioned.fill(
            top: 320, // Đẩy nội dung xuống thêm
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Food name
                    Text(
                      widget.food.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Food price
                    Consumer<Restaurant>(
                      builder: (context, restaurant, child) => Text(
                        restaurant.formatPrice(widget.food.price),
                        style: TextStyle(
                          fontSize: 22,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Food description
                    Text(
                      widget.food.description,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),

                    const SizedBox(height: 16),

                    Divider(color: Theme.of(context).colorScheme.secondary),

                    const SizedBox(height: 16),

                    // Add-on section
                    Text(
                      "Add-ons",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

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
                                restaurant.formatPrice(addon.price),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
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

                    const SizedBox(height: 16),

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
          ),
        ],
      ),
    );
  }
}
