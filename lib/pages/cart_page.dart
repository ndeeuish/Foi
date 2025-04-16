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
  void _removeFromCart(Restaurant restaurant, CartItem cartItem) {
    restaurant.removeFromCart(cartItem);
  }

  double _calculateTotal(List<CartItem> cart) {
    return cart.fold(0, (total, item) => total + (item.food.price * item.quantity));
  }

  String _selectedPaymentMethod = "Cash";

  @override
  Widget build(BuildContext context) {
    return Consumer<Restaurant>(
      builder: (context, restaurant, child) {
        final userCart = restaurant.cart;
        final totalPrice = _calculateTotal(userCart);

        return Scaffold(
          appBar: AppBar(
            title: const Text("Cart"),
            backgroundColor: Colors.transparent,
            foregroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: [
              IconButton(
                onPressed: userCart.isEmpty
                    ? null
                    : () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Are you sure want to clear the cart?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  restaurant.clearCart();
                                },
                                child: const Text("Yes"),
                              ),
                            ],
                          ),
                        );
                      },
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: userCart.isEmpty
                    ? const Center(child: Text("Cart is empty.."))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: userCart.length,
                        itemBuilder: (context, index) {
                          final cartItem = userCart[index];
                          return Dismissible(
                            key: ValueKey(cartItem.food.name + cartItem.quantity.toString()),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              _removeFromCart(restaurant, cartItem);
                            },
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            child: MyCartTile(cartItem: cartItem),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select Payment Method:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      value: _selectedPaymentMethod,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedPaymentMethod = newValue!;
                        });
                      },
                      items: <String>["Cash", "Card", "VNPAY"]
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total:",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "\$${totalPrice.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    MyButton(
                      text: "Go to checkout",
                      onTap: userCart.isEmpty
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PaymentPage(
                                    selectedPaymentMethod: _selectedPaymentMethod,
                                    totalPrice: totalPrice,
                                  ),
                                ),
                              ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}