import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Collection của orders
  final CollectionReference orders =
      FirebaseFirestore.instance.collection('orders');

  // Collection của users
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  // Lưu đơn hàng vào Firestore
  Future<void> saveOrderToDatabase(String receipt, String paymentStatus) async {
    try {
      print('Saving order to Firebase:');
      print('Receipt: $receipt');
      print('Payment Status: $paymentStatus');

      await orders.add({
        'date':
            Timestamp.fromDate(DateTime.now()), // Sử dụng Timestamp cho ngày
        'order': receipt,
        'paymentStatus': paymentStatus,
      });

      print('Order saved successfully');
    } catch (e) {
      print('Error saving order: $e');
      throw Exception('Failed to save order: $e');
    }
  }

  // Lưu thông tin người dùng vào Firestore
  Future<void> saveUserProfile(
      String uid, Map<String, dynamic> userData) async {
    try {
      // Đảm bảo dữ liệu không chứa giá trị null không mong muốn
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
      // Đảm bảo dữ liệu không chứa giá trị null không mong muốn
      final cleanedData =
          updatedData.map((key, value) => MapEntry(key, value ?? ''));
      await users.doc(uid).update(cleanedData);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }
}
