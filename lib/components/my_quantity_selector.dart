import 'package:flutter/material.dart';
import 'package:foi/models/food.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final Food food;
  final VoidCallback onIncrement;
  final VoidCallback onDecremment;
  const QuantitySelector(
      {super.key,
      required this.quantity,
      required this.food,
      required this.onDecremment,
      required this.onIncrement});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(50),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          //decrease button
          GestureDetector(
            onTap: onDecremment,
            child: Icon(Icons.remove,
                size: 20, color: Theme.of(context).colorScheme.primary),
          ),

          //quantity count
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: 
              Text(
                quantity.toString(),
              ),
            ),
          ),

          //increase button
          GestureDetector(
            onTap: onIncrement,
            child: Icon(Icons.add,
                size: 20, color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }
}
