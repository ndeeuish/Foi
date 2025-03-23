import 'package:flutter/material.dart';
import 'package:foi/components/my_quantity_selector.dart';
import 'package:foi/models/cart_item.dart';
import 'package:foi/models/restaurant.dart';
import 'package:provider/provider.dart';

class MyCartTile extends StatelessWidget {
  final CartItem cartItem;
  const MyCartTile({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    return Consumer<Restaurant>(
      builder: (context, restaurant, child) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //food image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      cartItem.food.imagePath,
                      height: 100,
                      width: 100,
                    ),
                  ),

                  //name and price
                  Column(
                    children: [
                      //food name
                      Text(cartItem.food.name),
                      //food price
                      Text("\$${cartItem.food.price}",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      ),


                      SizedBox(height: 15,),

                      //increment or decrement quantity
                      QuantitySelector(
                      quantity: cartItem.quantity,
                      food: cartItem.food,
                      onDecremment: () {
                        restaurant.removeFromCart(cartItem);
                      },
                      onIncrement: () {
                        restaurant.addToCart(
                            cartItem.food, cartItem.selectedAddons);
                      }),
                    ],
                  ),

                  const Spacer(),

                  
                ],
              ),
            ),

            //addons
            SizedBox(
              height: cartItem.selectedAddons.isEmpty ? 0 : 60,
              child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left : 10, bottom: 10, right: 10),
                  children: cartItem.selectedAddons
                      .map(
                        (addon) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Row(
                              children: [
                                //addon name
                                Text(addon.name),
                                //addon price
                                Text(addon.price.toString()),
                              ],
                            ),
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary
                              )
                            ),
                            onSelected: (value) {},
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            labelStyle: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.inversePrimary,
                                fontSize: 12),
                          ),
                        ),
                      )
                      .toList()),
            ),
          ],
        ),
      ),
    );
  }
}
