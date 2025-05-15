import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foi/auth/services/auth_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection của orders
  final CollectionReference orders =
      FirebaseFirestore.instance.collection('orders');

  // Collection của users
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  // Lưu đơn hàng vào Firestore
  Future<void> saveOrderToDatabase(String receipt, String paymentStatus) async {
    try {
      print('=== SAVING ORDER TO FIREBASE ===');
      print('Receipt: $receipt');
      print('Payment Status: $paymentStatus');

      final user = AuthService().getCurrentUser();
      if (user == null) {
        print('Error: User not logged in');
        throw Exception('User not logged in');
      }
      print('User ID: ${user.uid}');

      // Parse receipt để lấy thông tin chi tiết
      final lines = receipt.split('\n');
      String totalItems = '0';
      String totalPrice = '0';
      String deliveryAddress = '';

      for (var line in lines) {
        if (line.contains('Total Items:')) {
          totalItems = line.split(':')[1].trim();
        } else if (line.contains('Total Price:')) {
          totalPrice = line.split(':')[1].trim();
        } else if (line.contains('Delivery to:')) {
          deliveryAddress = line.split(':')[1].trim();
        }
      }

      final orderData = {
        'userId': user.uid,
        'receipt': receipt,
        'paymentStatus': paymentStatus,
        'timestamp': Timestamp.fromDate(DateTime.now()),
        'totalItems': totalItems,
        'totalPrice': totalPrice,
        'deliveryAddress': deliveryAddress,
      };
      print('Order data to save: $orderData');

      final docRef = await orders.add(orderData);
      print('Order saved successfully with ID: ${docRef.id}');
    } catch (e) {
      print('Error saving order: $e');
      throw Exception('Failed to save order: $e');
    }
  }

  // Lưu thông tin người dùng vào Firestore
  Future<void> saveUserProfile(
      String uid, Map<String, dynamic> userData) async {
    try {
      final cleanedData =
          userData.map((key, value) => MapEntry(key, value ?? ''));
      await users.doc(uid).set(cleanedData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }

  // Lấy thông tin người dùng từ Firestore
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await users.doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        throw Exception('User profile not found for UID: $uid');
      }
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  // Cập nhật thông tin người dùng
  Future<void> updateUserProfile(
      String uid, Map<String, dynamic> updatedData) async {
    try {
      final cleanedData =
          updatedData.map((key, value) => MapEntry(key, value ?? ''));
      await users.doc(uid).update(cleanedData);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Get user orders
  Future<List<Map<String, dynamic>>> getUserOrders() async {
    try {
      print('=== GETTING USER ORDERS ===');
      final user = AuthService().getCurrentUser();
      if (user == null) {
        print('Error: User not logged in');
        throw Exception('User not logged in');
      }
      print('Getting orders for user: ${user.uid}');

      // Lấy tất cả orders của user hiện tại
      final ordersSnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .get();

      print('Found ${ordersSnapshot.docs.length} orders');

      // Chuyển đổi dữ liệu và sắp xếp theo thời gian mới nhất
      final orders = ordersSnapshot.docs.map((doc) {
        final data = doc.data();
        print('Processing order ${doc.id}:');
        print('Raw data: $data');

        final order = {
          'id': doc.id,
          'receipt': data['receipt'] ?? '',
          'paymentStatus': data['paymentStatus'] ?? 'pending',
          'timestamp': data['timestamp']?.toDate().toString() ?? 'N/A',
          'totalItems': data['totalItems'] ?? '0',
          'totalPrice': data['totalPrice'] ?? '0',
          'deliveryAddress': data['deliveryAddress'] ?? '',
        };
        print('Processed order: $order');
        return order;
      }).toList();

      // Sắp xếp theo thời gian mới nhất
      orders.sort((a, b) {
        final aTime = DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime(0);
        final bTime = DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime(0);
        return bTime.compareTo(aTime);
      });

      print('Returning ${orders.length} sorted orders');
      return orders;
    } catch (e) {
      print('FirestoreService - Error getting user orders: $e');
      throw Exception('Failed to get user orders: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final orderRef = _firestore.collection('orders').doc(orderId);
      await orderRef.update({'paymentStatus': status});
      print('Order $orderId updated to status: $status');
    } catch (e) {
      print('Error updating order status: $e');
      throw Exception('Failed to update order status');
    }
  }
}
