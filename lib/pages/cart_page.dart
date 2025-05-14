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
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green.shade700,
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                'Voucher applied! Discount ${restaurant.formatPrice(result['discount'])}',
              ),
            ],
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
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Flexible(child: Text(_voucherError!)),
            ],
          ),
        ),
      );
      print('CartPage - Voucher error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
              ? '0'
              : restaurant.formatPrice(restaurant.deliveryFee * 1000);
          print(
              'CartPage - basePrice=$basePrice, discountAmount=$discountAmount, voucherCode=$voucherCode, totalPrice=$totalPrice, deliveryFee=$deliveryFee');

          return Scaffold(
            appBar: AppBar(
              title: const Text('Your Cart'),
              centerTitle: true,
              elevation: 0,
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.onSurface,
              actions: [
                IconButton(
                  onPressed: userCart.isEmpty
                      ? null
                      : () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Clear cart?'),
                              content: const Text(
                                  'All items will be removed from your cart.'),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel',
                                      style: TextStyle(
                                          color: colorScheme.secondary)),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    restaurant.clearCart();
                                    _voucherController.clear();
                                    setState(() => _voucherError = null);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.error,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Clear'),
                                ),
                              ],
                            ),
                          );
                        },
                  icon: Icon(
                    Icons.delete_outlined,
                    color: userCart.isEmpty ? Colors.grey : colorScheme.error,
                  ),
                ),
              ],
            ),
            body: userCart.isEmpty
                ? _buildEmptyCart(colorScheme)
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order Summary Section
                        _buildSectionHeader('Order Summary', textTheme),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: ListView.separated(
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
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(Icons.delete,
                                      color: Colors.white),
                                ),
                                child: MyCartTile(cartItem: cartItem),
                              );
                            },
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              thickness: 1,
                              color: Colors.grey.shade100,
                              indent: 16,
                              endIndent: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Delivery Address Section
                        _buildSectionHeader('Delivery Address', textTheme),
                        const SizedBox(height: 12),
                        _buildDeliveryAddressSection(restaurant, colorScheme),
                        const SizedBox(height: 24),

                        // Payment Method Section
                        _buildSectionHeader('Payment Method', textTheme),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _selectedPaymentMethod,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedPaymentMethod = newValue!;
                                });
                              },
                              icon: Icon(Icons.keyboard_arrow_down,
                                  color: colorScheme.primary),
                              items: <String>[
                                'Cash',
                                'VNPAY'
                              ].map<DropdownMenuItem<String>>((String value) {
                                IconData icon;
                                switch (value) {
                                  case 'Cash':
                                    icon = Icons.money;
                                    break;
                                  case 'VNPAY':
                                    icon = Icons.payment;
                                    break;
                                  default:
                                    icon = Icons.payment;
                                }

                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Row(
                                    children: [
                                      Icon(icon,
                                          color: colorScheme.primary, size: 22),
                                      const SizedBox(width: 12),
                                      Text(value, style: textTheme.titleMedium),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Promo Code Section
                        _buildSectionHeader('Promo Code', textTheme),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _voucherController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter promo code',
                                    errorText: _voucherError,
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    prefixIcon: Icon(Icons.discount_outlined,
                                        color: colorScheme.primary),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 0, horizontal: 16),
                                  ),
                                  style: textTheme.bodyMedium,
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: userCart.isEmpty
                                    ? null
                                    : () => _applyVoucher(restaurant),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Apply'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Order Summary Section
                        _buildSectionHeader('Order Total', textTheme),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildPriceSummaryRow(
                                'Subtotal',
                                restaurant.formatPrice(basePrice),
                                textTheme,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(height: 1),
                              ),
                              _buildPriceSummaryRow(
                                'Delivery Fee',
                                deliveryFee,
                                textTheme,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(height: 1),
                              ),
                              _buildPriceSummaryRow(
                                'Discount (${discountAmount > 0 ? voucherCode : 'None'})',
                                discountAmount > 0
                                    ? '-${restaurant.formatPrice(discountAmount)}'
                                    : '0 VND',
                                textTheme,
                                valueColor: discountAmount > 0
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(height: 1),
                              ),
                              _buildPriceSummaryRow(
                                'Total',
                                restaurant.formatPrice(totalPrice),
                                textTheme.copyWith(
                                  titleMedium: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                isBold: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
            bottomNavigationBar: userCart.isEmpty
                ? null
                : Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, -1),
                        ),
                      ],
                    ),
                    child: Builder(
                      builder: (context) {
                        return MyButton(
                          text:
                              'Checkout · ${restaurant.formatPrice(totalPrice)}',
                          onTap: () {
                            if (restaurant.deliveryAddress.isEmpty) {
                              print('Delivery address is empty');
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Please enter a delivery address."),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            print('Navigating to PaymentPage...');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentPage(
                                  selectedPaymentMethod: _selectedPaymentMethod,
                                  basePrice: basePrice,
                                  discountAmount: discountAmount,
                                  voucherCode: restaurant.voucherCode,
                                  deliveryFee: restaurant.deliveryFee,
                                  totalPrice: totalPrice,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some delicious items to your cart',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('Browse Menu'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, TextTheme textTheme) {
    return Text(
      title,
      style: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  Widget _buildDeliveryAddressSection(
      Restaurant restaurant, ColorScheme colorScheme) {
    return StreamBuilder<String>(
      stream: _addressStreamController.stream,
      builder: (context, snapshot) {
        final address = snapshot.data ?? restaurant.deliveryAddress;
        print('CartPage - StreamBuilder triggered for address: $address');

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () async {
                  await MyCurrentLocation().openLocationSearchBox(context);
                  final restaurant =
                      Provider.of<Restaurant>(context, listen: false);
                  _addressStreamController.add(restaurant.deliveryAddress);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivery Location',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              restaurant.deliveryAddress.isEmpty
                                  ? 'Select Delivery Address'
                                  : restaurant.deliveryAddress,
                              style: TextStyle(
                                color: restaurant.deliveryAddress.isEmpty
                                    ? Colors.grey.shade400
                                    : Colors.black87,
                                fontWeight: restaurant.deliveryAddress.isEmpty
                                    ? FontWeight.normal
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.edit_location_alt_outlined,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: FutureBuilder<double>(
                  future: _deliveryService.fetchDistance(address),
                  builder: (context, distanceSnapshot) {
                    Icon icon;
                    String text;
                    Color color;

                    if (distanceSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      icon = Icon(Icons.sync,
                          color: Colors.amber.shade800, size: 18);
                      text = 'Calculating delivery distance...';
                      color = Colors.amber.shade800;
                    } else if (distanceSnapshot.hasError) {
                      print(
                          'CartPage - Distance fetch error: ${distanceSnapshot.error}');
                      icon = Icon(Icons.error_outline,
                          color: Colors.red.shade700, size: 18);
                      text = distanceSnapshot.error.toString().contains(
                              'Delivery only available within Vietnam')
                          ? 'Delivery only available within Vietnam.'
                          : 'Unable to calculate distance.';
                      color = Colors.red.shade700;
                    } else {
                      final distance = distanceSnapshot.data ?? 0.0;
                      icon = Icon(Icons.directions_bike_outlined,
                          color: Colors.green.shade700, size: 18);
                      text =
                          'Delivery Distance: ${distance.toStringAsFixed(2)} km';
                      color = Colors.green.shade700;
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          icon,
                          const SizedBox(width: 8),
                          Text(
                            text,
                            style: TextStyle(
                              fontSize: 13,
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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

  Widget _buildPriceSummaryRow(
    String label,
    String value,
    TextTheme textTheme, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
              : textTheme.titleMedium,
        ),
        Text(
          value,
          style: isBold
              ? textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                )
              : textTheme.titleMedium?.copyWith(color: valueColor),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _voucherController.dispose();
    _addressStreamController.close();
    super.dispose();
  }
}
