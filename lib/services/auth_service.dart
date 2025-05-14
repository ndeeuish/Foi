// // Kiểm tra xem user hiện tại có phải là admin không
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// Future<bool> isAdmin() async {
//   try {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return false;

//     final userDoc = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(user.uid)
//         .get();

//     return userDoc.data()?['role'] == 'ad';
//   } catch (e) {
//     print('Error checking admin role: $e');
//     return false;
//   }
// }
