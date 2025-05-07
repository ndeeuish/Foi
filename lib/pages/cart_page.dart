import 'dart:async';
import 'package:flutter/material.dart';
import 'package:foi/components/my_button.dart';
import 'package:foi/components/my_cart_tile.dart';
import 'package:foi/components/my_current_location.dart';
import 'package:foi/models/restaurant.dart';
import 'package:foi/auth/services/voucher_service.dart';
import 'package:foi/auth/services/delivery_service.dart';
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
  final DeliveryService _deliveryService = DeliveryService();
  String _selectedPaymentMethod = "Cash";
  final _addressStreamController = StreamController<String>.broadcast();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final restaurant = Provider.of<Restaurant>(context, listen: false);
      _addressStreamController.add(restaurant.deliveryAddress);
    });
  }

  void _removeFromCart(Restaurant restaurant, CartItem cartItem) {
    restaurant.removeFromCart(cartItem);
    _voucherController.clear();
    setState(() => _voucherError = null);
  }

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
      print(
          'CartPage - Voucher applied: code=${result['voucherCode']}, discount=${result['discount']}');
    } catch (e) {
      setState(
        () => _voucherError = e.toString().replaceFirst('Exception: ', ''),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_voucherError!)),
      );
      print('CartPage - Voucher error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _deliveryService),
      ],
      child: Consumer<Restaurant>(
        builder: (context, restaurant, child) {
          final userCart = restaurant.cart;
          final basePrice = restaurant.getBasePrice();
          final discountAmount = restaurant.discountAmount;
          final voucherCode = restaurant.voucherCode ?? 'None';
          final totalPrice = restaurant.getTotalPrice();
          final deliveryFee = restaurant.deliveryFee == 0
              ? 'N/A'
              : restaurant.formatPrice(restaurant.deliveryFee * 1000);
          print(
              'CartPage - basePrice=$basePrice, discountAmount=$discountAmount, voucherCode=$voucherCode, totalPrice=$totalPrice, deliveryFee=$deliveryFee');
          return Scaffold(
            appBar: AppBar(
              title: const Text('Cart'),
              centerTitle: true,
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
                                  'Are you sure you want to clear the cart?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    restaurant.clearCart();
                                    _voucherController.clear();
                                    setState(() => _voucherError = null);
                                  },
                                  child: const Text('Yes'),
                                ),
                              ],
                            ),
                          );
                        },
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Summary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  userCart.isEmpty
                      ? const Center(child: Text('Cart is empty'))
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: userCart.length,
                          itemBuilder: (context, index) {
                            final cartItem = userCart[index];
                            return Dismissible(
                              key: ValueKey(cartItem.food.name +
                                  cartItem.quantity.toString()),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) =>
                                  _removeFromCart(restaurant, cartItem),
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              child: MyCartTile(cartItem: cartItem),
                            );
                          },
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                        ),
                  const SizedBox(height: 16),
                  const Text(
                    'Delivery Address',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder<String>(
                    stream: _addressStreamController.stream,
                    builder: (context, snapshot) {
                      final address =
                          snapshot.data ?? restaurant.deliveryAddress;
                      print(
                          'CartPage - StreamBuilder triggered for address: $address');
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await MyCurrentLocation()
                                  .openLocationSearchBox(context);
                              final restaurant = Provider.of<Restaurant>(
                                  context,
                                  listen: false);
                              _addressStreamController
                                  .add(restaurant.deliveryAddress);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      restaurant.deliveryAddress.isEmpty
                                          ? 'Select Address'
                                          : restaurant.deliveryAddress,
                                      style: TextStyle(
                                        color:
                                            restaurant.deliveryAddress.isEmpty
                                                ? Colors.grey
                                                : Colors.black,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.edit),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<double>(
                            future: _deliveryService.fetchDistance(address),
                            builder: (context, distanceSnapshot) {
                              if (distanceSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text(
                                  'Delivery Distance: Loading...',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                );
                              }
                              if (distanceSnapshot.hasError) {
                                print(
                                    'CartPage - Distance fetch error: ${distanceSnapshot.error}');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      distanceSnapshot.error.toString().contains(
                                              'Delivery only available within Vietnam')
                                          ? 'Delivery only available within Vietnam. Please enter a valid address.'
                                          : 'Unable to calculate distance. Please check your address or network connection.',
                                    ),
                                  ),
                                );
                                return const Text(
                                  'Delivery Distance: 0.00 km',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                );
                              }
                              final distance = distanceSnapshot.data ?? 0.0;
                              return Text(
                                'Delivery Distance: ${distance.toStringAsFixed(2)} km',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select Payment Method:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: _selectedPaymentMethod,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedPaymentMethod = newValue!;
                      });
                    },
                    items: <String>['Cash', 'Card', 'VNPAY']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Promo Code',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _voucherController,
                          decoration: InputDecoration(
                            hintText: 'Enter promo code',
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
                          'Apply',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Subtotal:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            restaurant.formatPrice(basePrice),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Delivery Fee:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            deliveryFee,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Discount (${discountAmount > 0 ? voucherCode : 'None'}):',
                            style: TextStyle(
                              fontSize: 16,
                              color: discountAmount > 0
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                          Text(
                            discountAmount > 0
                                ? '-${restaurant.formatPrice(discountAmount)}'
                                : '0 VND',
                            style: TextStyle(
                              fontSize: 16,
                              color: discountAmount > 0
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            restaurant.formatPrice(totalPrice),
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.center,
                        child: MyButton(
                          text: 'Checkout',
                          onTap: userCart.isEmpty ||
                                  restaurant.deliveryAddress.isEmpty ||
                                  _selectedPaymentMethod == 'Not selected'
                              ? null
                              : () {
                                  print(
                                      'CartPage - Navigating to PaymentPage with method: $_selectedPaymentMethod');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PaymentPage(
                                        selectedPaymentMethod:
                                            _selectedPaymentMethod,
                                        basePrice: basePrice,
                                        discountAmount: discountAmount,
                                        voucherCode: restaurant.voucherCode,
                                        deliveryFee: restaurant.deliveryFee,
                                        totalPrice: totalPrice,
                                      ),
                                    ),
                                  );
                                },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _voucherController.dispose();
    _addressStreamController.close();
    super.dispose();
  }
}
