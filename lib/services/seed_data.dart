import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foi/models/food.dart';

class SeedData {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedFoodData() async {
    try {
      print('SeedData - Starting to seed food data');
      
      // Get existing data
      print('SeedData - Getting existing data');
      final QuerySnapshot existingData = await _firestore.collection('foods').get();
      print('SeedData - Found ${existingData.docs.length} existing documents');
      
      // Create a set of existing food names for duplicate checking
      final Set<String> existingFoodNames = existingData.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['name'] as String)
          .toSet();
      
      // Add sample food items
      final List<Map<String, dynamic>> foods = [
        {
          'name': 'Classic Cheeseburger',
          'description': 'A beef patty with cheddar, lettuce, tomato and onion',
          'imagePath': 'lib/images/burgers/classic.png',
          'price': 35000,
          'category': 'burgers',
          'availableAddons': [
            {'name': 'Extra cheese', 'price': 5000},
            {'name': 'Bacon', 'price': 10000},
            {'name': 'Pickle', 'price': 5000},
          ],
        },
        {
          'name': 'Chicken Burger',
          'description': 'A crispy chicken patty with lettuce, mayo, and tomato',
          'imagePath': 'lib/images/burgers/chicken.png',
          'price': 40000,
          'category': 'burgers',
          'availableAddons': [
            {'name': 'Extra cheese', 'price': 5000},
            {'name': 'Bacon', 'price': 10000},
            {'name': 'Pickle', 'price': 5000},
          ],
        },
        {
          'name': 'BBQ Burger',
          'description': 'Smokey BBQ sauce, crispy bacon with lettuce, tomato, and onion',
          'imagePath': 'lib/images/burgers/beef.png',
          'price': 45000,
          'category': 'burgers',
          'availableAddons': [
            {'name': 'Extra cheese', 'price': 5000},
            {'name': 'Bacon', 'price': 10000},
            {'name': 'Pickle', 'price': 5000},
          ],
        },
        {
          'name': 'Shrimp Burger',
          'description': 'A crispy shrimp patty with tartar sauce and lettuce',
          'imagePath': 'lib/images/burgers/shrimp.png',
          'price': 50000,
          'category': 'burgers',
          'availableAddons': [
            {'name': 'Extra cheese', 'price': 5000},
            {'name': 'Bacon', 'price': 10000},
            {'name': 'Pickle', 'price': 5000},
          ],
        },
        {
          'name': 'Double Burger',
          'description': 'Two beef patties with cheddar, lettuce, tomato, and onion',
          'imagePath': 'lib/images/burgers/double.png',
          'price': 60000,
          'category': 'burgers',
          'availableAddons': [
            {'name': 'Extra cheese', 'price': 5000},
            {'name': 'Bacon', 'price': 10000},
            {'name': 'Pickle', 'price': 5000},
          ],
        },
        {
          'name': 'Caesar Salad',
          'description': 'Fresh romaine lettuce with croutons, parmesan cheese, and Caesar dressing',
          'imagePath': 'lib/images/salads/caesar.png',
          'price': 30000,
          'category': 'salads',
          'availableAddons': [
            {'name': 'Grilled chicken', 'price': 10000},
            {'name': 'Extra parmesan', 'price': 5000},
            {'name': 'Bacon bits', 'price': 7000},
          ],
        },
        {
          'name': 'Chicken Salad',
          'description': 'Grilled chicken breast on a bed of mixed greens with cherry tomatoes and vinaigrette',
          'imagePath': 'lib/images/salads/chicken.png',
          'price': 35000,
          'category': 'salads',
          'availableAddons': [
            {'name': 'Extra chicken', 'price': 10000},
            {'name': 'Avocado', 'price': 7000},
            {'name': 'Feta cheese', 'price': 5000},
          ],
        },
        {
          'name': 'Mushroom Salad',
          'description': 'Sautéed mushrooms with spinach, arugula, and balsamic dressing',
          'imagePath': 'lib/images/salads/mushroom.png',
          'price': 32000,
          'category': 'salads',
          'availableAddons': [
            {'name': 'Grilled tofu', 'price': 7000},
            {'name': 'Walnuts', 'price': 5000},
            {'name': 'Goat cheese', 'price': 6000},
          ],
        },
        {
          'name': 'Spinach Salad',
          'description': 'Fresh baby spinach with sliced strawberries, almonds, and honey mustard dressing',
          'imagePath': 'lib/images/salads/spinach.png',
          'price': 35000,
          'category': 'salads',
          'availableAddons': [
            {'name': 'Blue cheese', 'price': 6000},
            {'name': 'Cranberries', 'price': 5000},
            {'name': 'Grilled chicken', 'price': 10000},
          ],
        },
        {
          'name': 'Shrimp Salad',
          'description': 'Grilled shrimp with mixed greens, avocado, and citrus vinaigrette',
          'imagePath': 'lib/images/salads/shrimp.png',
          'price': 40000,
          'category': 'salads',
          'availableAddons': [
            {'name': 'Extra shrimp', 'price': 12000},
            {'name': 'Mango slices', 'price': 6000},
            {'name': 'Cashews', 'price': 5000},
          ],
        },
        {
          'name': 'French Fries',
          'description': 'Crispy golden fries with a side of ketchup',
          'imagePath': 'lib/images/sides/fries.png',
          'price': 30000,
          'category': 'sides',
          'availableAddons': [
            {'name': 'Cheese sauce', 'price': 5000},
            {'name': 'Bacon bits', 'price': 7000},
            {'name': 'Garlic butter', 'price': 4000},
          ],
        },
        {
          'name': 'Mac and Cheese',
          'description': 'Creamy macaroni with melted cheddar cheese',
          'imagePath': 'lib/images/sides/mac_cheese.png',
          'price': 20000,
          'category': 'sides',
          'availableAddons': [
            {'name': 'Extra cheese', 'price': 5000},
            {'name': 'Truffle oil', 'price': 8000},
            {'name': 'Bacon bits', 'price': 7000},
          ],
        },
        {
          'name': 'Onion Rings',
          'description': 'Crispy battered onion rings served with a tangy dipping sauce',
          'imagePath': 'lib/images/sides/onion_rings.png',
          'price': 18000,
          'category': 'sides',
          'availableAddons': [
            {'name': 'Spicy mayo', 'price': 4000},
            {'name': 'BBQ sauce', 'price': 4000},
            {'name': 'Extra crispy', 'price': 3000},
          ],
        },
        {
          'name': 'Egg',
          'description': 'Perfectly cooked egg, available fried or boiled',
          'imagePath': 'lib/images/sides/egg.png',
          'price': 8000,
          'category': 'sides',
          'availableAddons': [
            {'name': 'Double egg', 'price': 5000},
            {'name': 'Soy sauce', 'price': 2000},
            {'name': 'Chili flakes', 'price': 2000},
          ],
        },
        {
          'name': 'Chips',
          'description': 'Crunchy potato chips with a variety of flavors',
          'imagePath': 'lib/images/sides/chips.png',
          'price': 12000,
          'category': 'sides',
          'availableAddons': [
            {'name': 'Cheddar seasoning', 'price': 4000},
            {'name': 'Spicy seasoning', 'price': 4000},
            {'name': 'Ranch dip', 'price': 5000},
          ],
        },
        {
          'name': 'Beer',
          'description': 'Chilled refreshing beer, perfect for any meal',
          'imagePath': 'lib/images/drinks/beer.png',
          'price': 20000,
          'category': 'drinks',
          'availableAddons': [
            {'name': 'Extra cold', 'price': 2000},
            {'name': 'Lemon slice', 'price': 2000},
            {'name': 'Salt rim', 'price': 3000},
          ],
        },
        {
          'name': 'Fanta',
          'description': 'Fizzy orange soda with a sweet and tangy taste',
          'imagePath': 'lib/images/drinks/fanta.png',
          'price': 15000,
          'category': 'drinks',
          'availableAddons': [
            {'name': 'Extra ice', 'price': 2000},
            {'name': 'Lemon slice', 'price': 2000},
            {'name': 'Large size', 'price': 5000},
          ],
        },
        {
          'name': 'Iced Tea',
          'description': 'Refreshing iced tea with a hint of lemon',
          'imagePath': 'lib/images/drinks/icetea.png',
          'price': 12000,
          'category': 'drinks',
          'availableAddons': [
            {'name': 'Honey', 'price': 3000},
            {'name': 'Mint leaves', 'price': 2000},
            {'name': 'Extra lemon', 'price': 2000},
          ],
        },
        {
          'name': 'Coke',
          'description': 'Classic Coca-Cola with a bold and crisp taste',
          'imagePath': 'lib/images/drinks/coke.png',
          'price': 15000,
          'category': 'drinks',
          'availableAddons': [
            {'name': 'Extra ice', 'price': 2000},
            {'name': 'Lime wedge', 'price': 2000},
            {'name': 'Large size', 'price': 5000},
          ],
        },
        {
          'name': 'Water',
          'description': 'Pure and refreshing bottled water',
          'imagePath': 'lib/images/drinks/water.png',
          'price': 10000,
          'category': 'drinks',
          'availableAddons': [
            {'name': 'Chilled', 'price': 2000},
            {'name': 'Lemon slice', 'price': 2000},
            {'name': 'Sparkling upgrade', 'price': 5000},
          ],
        },
        {
          'name': 'Brownie',
          'description': 'Rich and fudgy chocolate brownie topped with walnuts',
          'imagePath': 'lib/images/desserts/brownie.png',
          'price': 30000,
          'category': 'desserts',
          'availableAddons': [
            {'name': 'Vanilla ice cream', 'price': 7000},
            {'name': 'Chocolate syrup', 'price': 4000},
            {'name': 'Extra walnuts', 'price': 3000},
          ],
        },
        {
          'name': 'Cake',
          'description': 'Soft and moist cake with layers of chocolate and nut',
          'imagePath': 'lib/images/desserts/cake.png',
          'price': 25000,
          'category': 'desserts',
          'availableAddons': [
            {'name': 'Extra cream', 'price': 4000},
            {'name': 'Berry topping', 'price': 7000},
            {'name': 'Chocolate shavings', 'price': 5000},
          ],
        },
        {
          'name': 'Lemon Pie',
          'description': 'Lemon pie with layers of cream',
          'imagePath': 'lib/images/desserts/pie.png',
          'price': 18000,
          'category': 'desserts',
          'availableAddons': [
            {'name': 'Chocolate chips', 'price': 4000},
            {'name': 'Caramel drizzle', 'price': 4000},
            {'name': 'Waffle cone', 'price': 3000},
          ],
        },
        {
          'name': 'Mousse',
          'description': 'Light and airy chocolate mousse with a rich texture',
          'imagePath': 'lib/images/desserts/mousse.png',
          'price': 22000,
          'category': 'desserts',
          'availableAddons': [
            {'name': 'Whipped cream', 'price': 4000},
            {'name': 'Cocoa powder', 'price': 3000},
            {'name': 'Raspberry sauce', 'price': 5000},
          ],
        },
        {
          'name': 'Macaron',
          'description': 'Delicate French macarons with a soft and chewy center',
          'imagePath': 'lib/images/desserts/macaron.png',
          'price': 30000,
          'category': 'desserts',
          'availableAddons': [
            {'name': 'Mixed flavors', 'price': 10000},
            {'name': 'Extra filling', 'price': 7000},
            {'name': 'Gold flakes', 'price': 12000},
          ],
        },
      ];

      // Add each food item to Firestore, skipping duplicates
      print('SeedData - Adding ${foods.length} new food items');
      int addedCount = 0;
      int skippedCount = 0;
      
      for (var food in foods) {
        if (existingFoodNames.contains(food['name'])) {
          print('SeedData - Skipping duplicate food item: ${food['name']}');
          skippedCount++;
          continue;
        }
        
        print('SeedData - Adding food item: ${food['name']}');
        await _firestore.collection('foods').add(food);
        addedCount++;
      }

      // Verify the data
      final QuerySnapshot verifyData = await _firestore.collection('foods').get();
      print('SeedData - Verification: Found ${verifyData.docs.length} documents after seeding');
      print('SeedData - Added $addedCount new items, skipped $skippedCount duplicates');
      
      for (var doc in verifyData.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print('SeedData - Document ${doc.id}: ${data['name']}');
      }

      print('SeedData - Successfully seeded food data');
    } catch (e) {
      print('SeedData - Error seeding food data: $e');
      rethrow;
    }
  }
}