import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VoucherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Apply voucher by querying Firestore
  Future<Map<String, dynamic>> applyVoucher(
      String code, double cartTotal) async {
    try {
      // Query vouchers collection
      final querySnapshot = await _firestore
          .collection('vouchers')
          .where('code', isEqualTo: code.trim().toUpperCase())
          .where('status', isEqualTo: 'active')
          .where('expiry', isGreaterThanOrEqualTo: Timestamp.now())
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Voucher code does not exist');
      }

      final voucher = querySnapshot.docs.first.data();

      // Check minimum order
      if (cartTotal < voucher['minOrder']) {
        throw Exception(
            'Order does not meet the minimum value of ${voucher['minOrder'].toInt()} VND');
      }

      // Calculate discount
      double discount = 0.0;
      if (voucher['type'] == 'fixed') {
        discount = voucher['value'].toDouble();
      } else if (voucher['type'] == 'percentage') {
        discount = cartTotal * (voucher['value'] / 100);
      }

      // Ensure discount doesn't exceed cart total
      discount = discount > cartTotal ? cartTotal : discount;

      print('VoucherService - Applied voucher "$code": Discount = $discount');
      return {
        'discount': discount,
        'voucherCode': voucher['code'],
      };
    } catch (e) {
      print('VoucherService - Error applying voucher "$code": $e');
      throw e;
    }
  }
}
