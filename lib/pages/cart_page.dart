import 'package:flutter/material.dart';
import 'package:foi/components/my_button.dart';
import 'package:foi/components/my_cart_tile.dart';
import 'package:foi/models/cart_item.dart';
import 'package:foi/models/restaurant.dart';
import 'package:foi/pages/payment_page.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Restaurant>(
      builder: (context, restaurant, child) {
        //cart
        final userCart = restaurant.cart;

        //Scaffold Ui
        return Scaffold(
          appBar: AppBar(
            title: Text("Cart"),
            backgroundColor: Colors.transparent,
            foregroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: [
              //clear cart button
              IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: const Text(
                                "Are you sure want to clear the cart?"),
                            actions: [
                              //cancel button
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Cancel"),
                              ),

                              //yes button
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  restaurant.clearCart();
                                },
                                child: Text("Yes"),
                              ),
                            ],
                          ));
                },
                icon: const Icon(Icons.delete),
              )
            ],
          ),
          body: Column(
            children: [
              // List of cart
              Expanded(
                child: userCart.isEmpty
                    ? const Center(
                        child: Text("Cart is empty.."),
                      )
                    : ListView.builder(
                        itemCount: userCart.length,
                        itemBuilder: (context, index) {
                          // Get individual cart item
                          final cartItem = userCart[index];

                          // Return cart tile with Dismissible
                          return Dismissible(
                            key: Key(cartItem.food.name +
                                index.toString()), // Key duy nhất
                            direction: DismissDirection
                                .endToStart, // Vuốt từ phải sang trái
                            onDismissed: (direction) {
                              Future.delayed(Duration.zero, () {
                                // Xóa item
                                setState(() {
                                  restaurant.removeFromCart(cartItem);
                                });
                              });
                            },
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            child: MyCartTile(cartItem: cartItem),
                          );
                        },
                      ),
              ),

              //button to pay
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 10.0),
                child: MyButton(
                  text: "Go to checkout",
                  onTap: userCart.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PaymentPage(),
                            ),
                          );
                        },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
