import 'package:flutter/material.dart';
import 'package:foi/models/food.dart';
import 'package:foi/models/restaurant.dart';
import 'package:provider/provider.dart';

class FoodTile extends StatelessWidget {
  final Food food;
  final void Function()? onTap;

  const FoodTile({
    super.key,
    required this.food,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                // Food details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Food name
                      Text(food.name),
                      // Food price (formatted as 70.000₫)
                      Consumer<Restaurant>(
                        builder: (context, restaurant, child) => Text(
                          restaurant.formatPrice(food.price),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Food description
                      Text(
                        food.description,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 15),

                // Food image
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      food.imagePath,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Divider line
        Divider(
          color: Theme.of(context).colorScheme.tertiary,
          endIndent: 25,
          indent: 25,
        ),
      ],
    );
  }
}
