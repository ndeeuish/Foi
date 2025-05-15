import 'package:flutter/material.dart';
import 'package:foi/auth/database/firestore.dart';
import 'package:foi/models/restaurant.dart';
import 'package:provider/provider.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  String? expandedOrderId;
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final orders = await _firestoreService.getUserOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateOrderStatus(String orderId, String status) async {
    try {
      await _firestoreService.updateOrderStatus(orderId, status);
      setState(() {
        final orderIndex = _orders.indexWhere((order) => order['id'] == orderId);
        if (orderIndex != -1) {
          _orders[orderIndex]['paymentStatus'] = status;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Order status updated to $status!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order History"),
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Error: $_error'))
                : _orders.isEmpty
                    ? const Center(child: Text('No orders found'))
                    : ListView.builder(
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          final orderId = order['id'] as String;
                          final isExpanded = orderId == expandedOrderId;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    expandedOrderId =
                                        isExpanded ? null : orderId;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Order #${orderId.substring(0, 8)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(
                                                          order['paymentStatus'])
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  order['paymentStatus'] ??
                                                      'Unknown',
                                                  style: TextStyle(
                                                    color: _getStatusColor(
                                                        order['paymentStatus']),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              AnimatedRotation(
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                turns: isExpanded ? 0.5 : 0,
                                                child: const Icon(
                                                    Icons.keyboard_arrow_down),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Date: ${order['timestamp']}',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .inversePrimary,
                                        ),
                                      ),
                                      AnimatedCrossFade(
                                        firstChild: const SizedBox.shrink(),
                                        secondChild: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 16),
                                            const Divider(),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Total Items: ${order['totalItems'] ?? 0}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  'Total Price: ${order['totalPrice'] ?? '0 ₫'}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'Delivery Address:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                                order['deliveryAddress'] ??
                                                    'No address'),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'Receipt Details:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              order['receipt'] ?? 'No receipt',
                                              style: const TextStyle(
                                                fontFamily: 'Roboto',
                                                fontSize: 14,
                                                height: 1.5,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            if (order['paymentStatus'] == 'Paid' ||
                                                order['paymentStatus'] == 'Pending')
                                              ElevatedButton(
                                                onPressed: () async {
                                                  await _updateOrderStatus(
                                                      orderId, "Delivered");
                                                },
                                                child: const Text("Confirm Delivery"),
                                              ),
                                          ],
                                        ),
                                        crossFadeState: isExpanded
                                            ? CrossFadeState.showSecond
                                            : CrossFadeState.showFirst,
                                        duration:
                                            const Duration(milliseconds: 300),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'delivered':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
} 