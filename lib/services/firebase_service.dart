import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foi/models/food.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all food items
  Future<List<Food>> getFoodItems() async {
    try {
      print('FirebaseService - Getting food items from Firestore');
      final QuerySnapshot snapshot = await _firestore.collection('foods').get();
      print('FirebaseService - Got ${snapshot.docs.length} food items');
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print('FirebaseService - Processing food item: ${data['name']}');
        return Food(
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          imagePath: data['imagePath'] ?? '',
          price: (data['price'] ?? 0).toDouble(),
          category: FoodCategory.values.firstWhere(
            (e) => e.toString() == 'FoodCategory.${data['category']}',
            orElse: () => FoodCategory.burgers,
          ),
          availableAddons: (data['availableAddons'] as List<dynamic>?)?.map((addon) {
            return Addon(
              name: addon['name'] ?? '',
              price: (addon['price'] ?? 0).toDouble(),
            );
          }).toList() ?? [],
        );
      }).toList();
    } catch (e) {
      print('FirebaseService - Error getting food items: $e');
      return [];
    }
  }

  // Add a new food item
  Future<void> addFoodItem(Food food) async {
    try {
      await _firestore.collection('foods').add({
        'name': food.name,
        'description': food.description,
        'imagePath': food.imagePath,
        'price': food.price,
        'category': food.category.toString().split('.').last,
        'availableAddons': food.availableAddons.map((addon) => {
          'name': addon.name,
          'price': addon.price,
        }).toList(),
      });
    } catch (e) {
      print('Error adding food item: $e');
      rethrow;
    }
  }

  // Update a food item
  Future<void> updateFoodItem(String id, Food food) async {
    try {
      await _firestore.collection('foods').doc(id).update({
        'name': food.name,
        'description': food.description,
        'imagePath': food.imagePath,
        'price': food.price,
        'category': food.category.toString().split('.').last,
        'availableAddons': food.availableAddons.map((addon) => {
          'name': addon.name,
          'price': addon.price,
        }).toList(),
      });
    } catch (e) {
      print('Error updating food item: $e');
      rethrow;
    }
  }

  // Delete a food item
  Future<void> deleteFoodItem(String id) async {
    try {
      await _firestore.collection('foods').doc(id).delete();
    } catch (e) {
      print('Error deleting food item: $e');
      rethrow;
    }
  }
} 