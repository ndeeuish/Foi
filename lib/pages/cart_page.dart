import 'package:flutter/material.dart';
import 'package:foi/components/my_button.dart';
import 'package:foi/components/my_cart_tile.dart';
import 'package:foi/components/my_current_location.dart';
import 'package:foi/models/restaurant.dart';
import 'package:foi/auth/services/voucher_service.dart';
import 'package:foi/auth/services/delivery_service.dart';
import 'package:foi/pages/payment_page.dart';
import 'package:latlong2/latlong.dart';
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
  double _distance = 0.0;
  String? _lastAddress; // Track last address to detect changes
  LatLng? _lastCustomerLocation; // Track last customer location
  String _selectedPaymentMethod = "Cash";

  @override
  void initState() {
    super.initState();
    _updateDistance();
  }

  void _updateDistance({String? newAddress}) async {
    final restaurant = Provider.of<Restaurant>(context, listen: false);
    final address = newAddress ?? restaurant.deliveryAddress;
    print('CartPage - Updating distance for address: $address');
    if (address.trim().isEmpty) {
      setState(() {
        _distance = 0.0;
        _lastAddress = address;
        _lastCustomerLocation = null;
      });
      print('CartPage - Empty address, distance set to 0.0');
      return;
    }
    LatLng? customerLocation = _deliveryService.customerLocation;
    if (customerLocation == null) {
      // Fallback: Try geocoding the address directly
      try {
        print(
            'CartPage - Customer location null, attempting to geocode: $address');
        customerLocation =
            await _deliveryService.getCoordinatesFromAddress(address);
        await _deliveryService
            .updateDeliveryDetails(address); // Ensure customerLocation is set
      } catch (e) {
        print('CartPage - Geocoding fallback failed: $e');
        setState(() {
          _distance = 0.0;
          _lastAddress = address;
          _lastCustomerLocation = null;
        });
        return;
      }
    }
    try {
      final distance = await _deliveryService.getDistanceFromOSRM(
        _deliveryService.defaultRestaurantLocation,
        customerLocation,
      );
      setState(() {
        _distance = distance;
        _lastAddress = address;
        _lastCustomerLocation = customerLocation;
      });
      print(
          'CartPage - Updated distance: ${_distance.toStringAsFixed(2)} km for address: $address, location: $customerLocation');
    } catch (e) {
      print('CartPage - Error updating distance: $e');
      setState(() {
        _distance = 0.0;
        _lastAddress = address;
        _lastCustomerLocation = customerLocation;
      });
    }
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
      child: Consumer2<Restaurant, DeliveryService>(
        builder: (context, restaurant, deliveryService, child) {
          final userCart = restaurant.cart;
          final basePrice = restaurant.getBasePrice();
          final discountAmount = restaurant.discountAmount ?? 0.0;
          final voucherCode = restaurant.voucherCode ?? 'No voucher';
          final totalPrice = restaurant.getTotalPrice();
          // Check for address or location change
          if (restaurant.deliveryAddress != _lastAddress ||
              deliveryService.customerLocation != _lastCustomerLocation) {
            print(
                'CartPage - Detected change: address=${restaurant.deliveryAddress}, location=${deliveryService.customerLocation}');
            _updateDistance(newAddress: restaurant.deliveryAddress);
          }
          print(
              'CartPage - basePrice=$basePrice, discountAmount=$discountAmount, voucherCode=$voucherCode, totalPrice=$totalPrice');
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
                  // Delivery Distance
                  Text(
                    'Delivery Distance: ${_distance.toStringAsFixed(2)} km',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  // Test Button for Debugging
                  // Order Summary
                  const Text(
                    'Order Summary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  userCart.isEmpty
                      ? const Center(child: Text('Cart is empty'))
                      : ListView.builder(
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
                        ),
                  const SizedBox(height: 16),
                  // Delivery Address

                  GestureDetector(
                    onTap: () {
                      MyCurrentLocation().openLocationSearchBox(context);
                      // _updateDistance called via Consumer on address change
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
                                color: restaurant.deliveryAddress.isEmpty
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

                  const SizedBox(height: 10),
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
                  // Promo Code
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
                            hintText: 'Enter voucher code',
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
                  // Price Breakdown
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
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Checkout Button
                      Align(
                        alignment: Alignment.center,
                        child: MyButton(
                          text: 'Go to Checkout',
                          onTap: userCart.isEmpty ||
                                  restaurant.deliveryAddress.isEmpty ||
                                  _selectedPaymentMethod == 'Not selected'
                              ? null
                              : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PaymentPage(
                                        selectedPaymentMethod:
                                            _selectedPaymentMethod,
                                        basePrice: basePrice,
                                        discountAmount:
                                            restaurant.discountAmount,
                                        voucherCode: restaurant.voucherCode,
                                        totalPrice: totalPrice,
                                      ),
                                    ),
                                  ),
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
    super.dispose();
  }
}
