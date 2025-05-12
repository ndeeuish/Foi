import 'package:flutter/material.dart';
import 'package:foi/auth/database/firestore.dart';
import 'package:foi/models/restaurant.dart';
import 'package:foi/pages/my_receipt.dart';
import 'package:provider/provider.dart';

class DeliveryProgressPage extends StatefulWidget {
  final String receipt;
  final String paymentStatus;

  const DeliveryProgressPage({
    super.key,
    required this.receipt,
    required this.paymentStatus,
  });

  @override
  State<DeliveryProgressPage> createState() => _DeliveryProgressPageState();
}

class _DeliveryProgressPageState extends State<DeliveryProgressPage> {
  //get access to db
  FirestoreService db = FirestoreService();

  @override
  void initState() {
    super.initState();
    _saveOrder();
  }

  Future<void> _saveOrder() async {
    try {
      final restaurant = context.read<Restaurant>();
      print('DeliveryProgressPage - Payment Status: ${widget.paymentStatus}');
      print('DeliveryProgressPage - Receipt: ${widget.receipt}');
      
      // Lưu order vào database với receipt đã được truyền vào
      await db.saveOrderToDatabase(widget.receipt, widget.paymentStatus);
      
      // Clear cart sau khi đã lưu order
      //restaurant.clearCart();
    } catch (e) {
      print('DeliveryProgressPage - Error saving order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delivery in progress..."),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            final restaurant = context.read<Restaurant>();
            restaurant.clearCart(); 
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order Details",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(widget.receipt), // Hiển thị receipt từ giỏ hàng
            const SizedBox(height: 20),
            Text(
              "Payment Status: ${widget.paymentStatus}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Driver profile picture
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          // Driver details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Your driver",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  "Arriving in 10-15 minutes",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ],
            ),
          ),
          // Contact buttons
          Row(
            children: [
              IconButton(
                onPressed: () {
                  // TODO: Implement call functionality
                },
                icon: const Icon(Icons.phone),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Implement message functionality
                },
                icon: const Icon(Icons.message),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
