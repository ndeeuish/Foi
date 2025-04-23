import 'package:flutter/material.dart';
import 'package:foi/components/my_button.dart';
import 'package:foi/components/my_cart_tile.dart';
import 'package:foi/models/restaurant.dart';
import 'package:foi/auth/services/voucher_service.dart';
import 'package:foi/pages/payment_page.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final TextEditingController _voucherController = TextEditingController();
  String? _voucherError;

  // Remove item from cart
  void _removeFromCart(Restaurant restaurant, CartItem cartItem) {
    restaurant.removeFromCart(cartItem);
  }

  // Apply voucher
  void _applyVoucher(Restaurant restaurant) async {
    final voucherService = VoucherService();
    try {
      final result = await voucherService.applyVoucher(
        _voucherController.text,
        restaurant.getBasePrice(),
      );
      restaurant.applyVoucher(result['voucherCode'], result['discount']);
      setState(() => _voucherError = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Voucher applied successfully! Discount ${restaurant.formatPrice(result['discount'])}',
          ),
        ),
      );
    } catch (e) {
      setState(
        () => _voucherError = e.toString().replaceFirst('Exception: ', ''),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_voucherError!)),
      );
    }
  }

  // Default payment method
  String _selectedPaymentMethod = "Cash";

  @override
  Widget build(BuildContext context) {
    return Consumer<Restaurant>(
      builder: (context, restaurant, child) {
        final userCart = restaurant.cart;
        final basePrice = restaurant.getBasePrice();
        final totalPrice = restaurant.getTotalPrice();

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
                            title: const Text(
                              "Are you sure you want to clear the cart?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  restaurant.clearCart();
                                  _voucherController.clear();
                                  setState(() => _voucherError = null);
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
                    ? const Center(child: Text("Cart is empty"))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: userCart.length,
                        itemBuilder: (context, index) {
                          final cartItem = userCart[index];
                          return Dismissible(
                            key: ValueKey(
                              cartItem.food.name + cartItem.quantity.toString(),
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              _removeFromCart(restaurant, cartItem);
                              _voucherController.clear();
                              setState(() => _voucherError = null);
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select Payment Method:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                    // Voucher input
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _voucherController,
                            decoration: InputDecoration(
                              hintText: "Enter voucher code",
                              errorText: _voucherError,
                              border: const OutlineInputBorder(),
                            ),
                            style: const TextStyle(fontFamily: 'Roboto'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        MaterialButton(
                          onPressed: userCart.isEmpty
                              ? null
                              : () => _applyVoucher(restaurant),
                          color: Theme.of(context).colorScheme.primary,
                          child: const Text(
                            "Apply",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Price breakdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Cart Total:",
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          restaurant.formatPrice(basePrice),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    if (restaurant.discountAmount > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Discount (${restaurant.voucherCode}):",
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            "-${restaurant.formatPrice(restaurant.discountAmount)}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          restaurant.formatPrice(totalPrice),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    MyButton(
                      text: "Go to Checkout",
                      onTap: userCart.isEmpty
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PaymentPage(
                                    selectedPaymentMethod:
                                        _selectedPaymentMethod,
                                    basePrice: basePrice,
                                    discountAmount: restaurant.discountAmount,
                                    voucherCode: restaurant.voucherCode,
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

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }
}
