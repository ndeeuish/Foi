import 'package:flutter/foundation.dart';
import 'package:foi/models/food.dart';
import 'package:intl/intl.dart';

class Restaurant extends ChangeNotifier {
  // List of food menu items
  final List<Food> _menu = [
    // Burgers
    Food(
      name: "Classic Cheeseburger",
      description: "A beef patty with cheddar, lettuce, tomato and onion",
      imagePath: "lib/images/burgers/classic.png",
      price: 35000, // Price in VND, formatted as 35.000₫
      category: FoodCategory.burgers,
      availableAddons: [
        Addon(name: "Extra cheese", price: 5000),
        Addon(name: "Bacon", price: 10000),
        Addon(name: "Pickle", price: 5000),
      ],
    ),
    Food(
      name: "Chicken Burger",
      description: "A crispy chicken patty with lettuce, mayo, and tomato",
      imagePath: "lib/images/burgers/chicken.png",
      price: 40000,
      category: FoodCategory.burgers,
      availableAddons: [
        Addon(name: "Extra cheese", price: 5000),
        Addon(name: "Bacon", price: 10000),
        Addon(name: "Pickle", price: 5000),
      ],
    ),
    Food(
      name: "BBQ Burger",
      description:
          "Smokey BBQ sauce, crispy bacon with lettuce, tomato, and onion",
      imagePath: "lib/images/burgers/beef.png",
      price: 45000,
      category: FoodCategory.burgers,
      availableAddons: [
        Addon(name: "Extra cheese", price: 5000),
        Addon(name: "Bacon", price: 10000),
        Addon(name: "Pickle", price: 5000),
      ],
    ),
    Food(
      name: "Shrimp Burger",
      description: "A crispy shrimp patty with tartar sauce and lettuce",
      imagePath: "lib/images/burgers/shrimp.png",
      price: 50000,
      category: FoodCategory.burgers,
      availableAddons: [
        Addon(name: "Extra cheese", price: 5000),
        Addon(name: "Bacon", price: 10000),
        Addon(name: "Pickle", price: 5000),
      ],
    ),
    Food(
      name: "Double Burger",
      description: "Two beef patties with cheddar, lettuce, tomato, and onion",
      imagePath: "lib/images/burgers/double.png",
      price: 60000,
      category: FoodCategory.burgers,
      availableAddons: [
        Addon(name: "Extra cheese", price: 5000),
        Addon(name: "Bacon", price: 10000),
        Addon(name: "Pickle", price: 5000),
      ],
    ),

    // Salads
    Food(
      name: "Caesar Salad",
      description:
          "Fresh romaine lettuce with croutons, parmesan cheese, and Caesar dressing",
      imagePath: "lib/images/salads/caesar.png",
      price: 30000,
      category: FoodCategory.salads,
      availableAddons: [
        Addon(name: "Grilled chicken", price: 10000),
        Addon(name: "Extra parmesan", price: 5000),
        Addon(name: "Bacon bits", price: 7000),
      ],
    ),
    Food(
      name: "Chicken Salad",
      description:
          "Grilled chicken breast on a bed of mixed greens with cherry tomatoes and vinaigrette",
      imagePath: "lib/images/salads/chicken.png",
      price: 35000,
      category: FoodCategory.salads,
      availableAddons: [
        Addon(name: "Extra chicken", price: 10000),
        Addon(name: "Avocado", price: 7000),
        Addon(name: "Feta cheese", price: 5000),
      ],
    ),
    Food(
      name: "Mushroom Salad",
      description:
          "Sautéed mushrooms with spinach, arugula, and balsamic dressing",
      imagePath: "lib/images/salads/mushroom.png",
      price: 32000,
      category: FoodCategory.salads,
      availableAddons: [
        Addon(name: "Grilled tofu", price: 7000),
        Addon(name: "Walnuts", price: 5000),
        Addon(name: "Goat cheese", price: 6000),
      ],
    ),
    Food(
      name: "Spinach Salad",
      description:
          "Fresh baby spinach with sliced strawberries, almonds, and honey mustard dressing",
      imagePath: "lib/images/salads/spinach.png",
      price: 35000,
      category: FoodCategory.salads,
      availableAddons: [
        Addon(name: "Blue cheese", price: 6000),
        Addon(name: "Cranberries", price: 5000),
        Addon(name: "Grilled chicken", price: 10000),
      ],
    ),
    Food(
      name: "Shrimp Salad",
      description:
          "Grilled shrimp with mixed greens, avocado, and citrus vinaigrette",
      imagePath: "lib/images/salads/shrimp.png",
      price: 40000,
      category: FoodCategory.salads,
      availableAddons: [
        Addon(name: "Extra shrimp", price: 12000),
        Addon(name: "Mango slices", price: 6000),
        Addon(name: "Cashews", price: 5000),
      ],
    ),

    // Sides
    Food(
      name: "French Fries",
      description: "Crispy golden fries with a side of ketchup",
      imagePath: "lib/images/sides/fries.png",
      price: 30000,
      category: FoodCategory.sides,
      availableAddons: [
        Addon(name: "Cheese sauce", price: 5000),
        Addon(name: "Bacon bits", price: 7000),
        Addon(name: "Garlic butter", price: 4000),
      ],
    ),
    Food(
      name: "Mac and Cheese",
      description: "Creamy macaroni with melted cheddar cheese",
      imagePath: "lib/images/sides/mac_cheese.png",
      price: 20000,
      category: FoodCategory.sides,
      availableAddons: [
        Addon(name: "Extra cheese", price: 5000),
        Addon(name: "Truffle oil", price: 8000),
        Addon(name: "Bacon bits", price: 7000),
      ],
    ),
    Food(
      name: "Onion Rings",
      description:
          "Crispy battered onion rings served with a tangy dipping sauce",
      imagePath: "lib/images/sides/onion_rings.png",
      price: 18000,
      category: FoodCategory.sides,
      availableAddons: [
        Addon(name: "Spicy mayo", price: 4000),
        Addon(name: "BBQ sauce", price: 4000),
        Addon(name: "Extra crispy", price: 3000),
      ],
    ),
    Food(
      name: "Egg",
      description: "Perfectly cooked egg, available fried or boiled",
      imagePath: "lib/images/sides/egg.png",
      price: 8000,
      category: FoodCategory.sides,
      availableAddons: [
        Addon(name: "Double egg", price: 5000),
        Addon(name: "Soy sauce", price: 2000),
        Addon(name: "Chili flakes", price: 2000),
      ],
    ),
    Food(
      name: "Chips",
      description: "Crunchy potato chips with a variety of flavors",
      imagePath: "lib/images/sides/chips.png",
      price: 12000,
      category: FoodCategory.sides,
      availableAddons: [
        Addon(name: "Cheddar seasoning", price: 4000),
        Addon(name: "Spicy seasoning", price: 4000),
        Addon(name: "Ranch dip", price: 5000),
      ],
    ),

    // Drinks
    Food(
      name: "Beer",
      description: "Chilled refreshing beer, perfect for any meal",
      imagePath: "lib/images/drinks/beer.png",
      price: 20000,
      category: FoodCategory.drinks,
      availableAddons: [
        Addon(name: "Extra cold", price: 2000),
        Addon(name: "Lemon slice", price: 2000),
        Addon(name: "Salt rim", price: 3000),
      ],
    ),
    Food(
      name: "Fanta",
      description: "Fizzy orange soda with a sweet and tangy taste",
      imagePath: "lib/images/drinks/fanta.png",
      price: 15000,
      category: FoodCategory.drinks,
      availableAddons: [
        Addon(name: "Extra ice", price: 2000),
        Addon(name: "Lemon slice", price: 2000),
        Addon(name: "Large size", price: 5000),
      ],
    ),
    Food(
      name: "Iced Tea",
      description: "Refreshing iced tea with a hint of lemon",
      imagePath: "lib/images/drinks/icetea.png",
      price: 12000,
      category: FoodCategory.drinks,
      availableAddons: [
        Addon(name: "Honey", price: 3000),
        Addon(name: "Mint leaves", price: 2000),
        Addon(name: "Extra lemon", price: 2000),
      ],
    ),
    Food(
      name: "Coke",
      description: "Classic Coca-Cola with a bold and crisp taste",
      imagePath: "lib/images/drinks/coke.png",
      price: 15000,
      category: FoodCategory.drinks,
      availableAddons: [
        Addon(name: "Extra ice", price: 2000),
        Addon(name: "Lime wedge", price: 2000),
        Addon(name: "Large size", price: 5000),
      ],
    ),
    Food(
      name: "Water",
      description: "Pure and refreshing bottled water",
      imagePath: "lib/images/drinks/water.png",
      price: 10000,
      category: FoodCategory.drinks,
      availableAddons: [
        Addon(name: "Chilled", price: 2000),
        Addon(name: "Lemon slice", price: 2000),
        Addon(name: "Sparkling upgrade", price: 5000),
      ],
    ),

    // Desserts
    Food(
      name: "Brownie",
      description: "Rich and fudgy chocolate brownie topped with walnuts",
      imagePath: "lib/images/desserts/brownie.png",
      price: 30000,
      category: FoodCategory.desserts,
      availableAddons: [
        Addon(name: "Vanilla ice cream", price: 7000),
        Addon(name: "Chocolate syrup", price: 4000),
        Addon(name: "Extra walnuts", price: 3000),
      ],
    ),
    Food(
      name: "Cake",
      description: "Soft and moist cake with layers of chocolate and nut",
      imagePath: "lib/images/desserts/cake.png",
      price: 25000,
      category: FoodCategory.desserts,
      availableAddons: [
        Addon(name: "Extra cream", price: 4000),
        Addon(name: "Berry topping", price: 7000),
        Addon(name: "Chocolate shavings", price: 5000),
      ],
    ),
    Food(
      name: "Lemon Pie",
      description: "Lemon pie with layers of cream",
      imagePath: "lib/images/desserts/pie.png",
      price: 18000,
      category: FoodCategory.desserts,
      availableAddons: [
        Addon(name: "Chocolate chips", price: 4000),
        Addon(name: "Caramel drizzle", price: 4000),
        Addon(name: "Waffle cone", price: 3000),
      ],
    ),
    Food(
      name: "Mousse",
      description: "Light and airy chocolate mousse with a rich texture",
      imagePath: "lib/images/desserts/mousse.png",
      price: 22000,
      category: FoodCategory.desserts,
      availableAddons: [
        Addon(name: "Whipped cream", price: 4000),
        Addon(name: "Cocoa powder", price: 3000),
        Addon(name: "Raspberry sauce", price: 5000),
      ],
    ),
    Food(
      name: "Macaron",
      description: "Delicate French macarons with a soft and chewy center",
      imagePath: "lib/images/desserts/macaron.png",
      price: 30000,
      category: FoodCategory.desserts,
      availableAddons: [
        Addon(name: "Mixed flavors", price: 10000),
        Addon(name: "Extra filling", price: 7000),
        Addon(name: "Gold flakes", price: 12000),
      ],
    ),
  ];
  // User cart
  final List<CartItem> _cart = [];

  // Delivery address
  String _deliveryAddress = "";

  // Payment status
  String _paymentStatus = "Pending";

// Delivery fee (in VND)
  double _deliveryFee = 10000;

  // Getters
  List<Food> get menu => _menu;
  List<CartItem> get cart => _cart;
  String get deliveryAddress => _deliveryAddress;
  String get paymentStatus => _paymentStatus;

  // Format price in VND
  String formatPrice(double price) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  // Add to cart
  void addToCart(Food food, List<Addon> selectedAddons) {
    // Check if the food is already in the cart
    CartItem? cartItem = _cart.firstWhere(
      (item) {
        bool isSameFood = item.food == food;
        bool isSameAddons = listEquals(item.selectedAddons, selectedAddons);
        return isSameFood && isSameAddons;
      },
      orElse: () => CartItem(food: food, selectedAddons: selectedAddons),
    );

    if (_cart.contains(cartItem)) {
      cartItem.quantity++;
    } else {
      _cart.add(cartItem);
    }
    notifyListeners();
  }

  // Remove from cart
  void removeFromCart(CartItem cartItem) {
    if (_cart.contains(cartItem)) {
      if (cartItem.quantity > 1) {
        cartItem.quantity--;
      } else {
        _cart.remove(cartItem);
      }
      notifyListeners();
    }
  }

  double getBasePrice() {
    double total = 0.0;
    for (CartItem cartItem in _cart) {
      double itemTotal = cartItem.food.price;
      for (Addon addon in cartItem.selectedAddons) {
        itemTotal += addon.price;
      }
      total += itemTotal * cartItem.quantity;
    }
    return total;
  }

  // Calculate total price (base + delivery fee)
  double getTotalPrice() {
    double basePrice = getBasePrice();
    return basePrice + _deliveryFee;
  }

  // Get total item count
  int getTotalItemCount() {
    return _cart.fold(0, (sum, item) => sum + item.quantity);
  }

  // Generate receipt
  String displayCartReceipt() {
    final receipt = StringBuffer();
    receipt.writeln("Here is your receipt.");
    receipt.writeln();
    String formattedDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    receipt.writeln(formattedDate);
    receipt.writeln("-----------");
    for (final cartItem in _cart) {
      receipt.writeln(
          "${cartItem.quantity} x ${cartItem.food.name} - ${formatPrice(cartItem.totalPrice)}");
      if (cartItem.selectedAddons.isNotEmpty) {
        receipt
            .writeln("     Add-ons: ${_formatAddons(cartItem.selectedAddons)}");
      }
      receipt.writeln();
    }
    receipt.writeln("-----------");
    receipt.writeln("Total Items: ${getTotalItemCount()}");
    receipt.writeln("Delivery Fee: ${formatPrice(_deliveryFee)}");
    receipt.writeln("Total Price: ${formatPrice(getTotalPrice())}");
    receipt.writeln();
    receipt.writeln("Delivery to: $deliveryAddress");
    receipt.writeln("Payment Status: $_paymentStatus");
    return receipt.toString();
  }

  // Format addons for receipt
  String _formatAddons(List<Addon> addons) {
    return addons
        .map((addon) => "${addon.name} (${formatPrice(addon.price)})")
        .join(", ");
  }

  // Update delivery address
  void updateDeliveryAddress(String newAddress) {
    _deliveryAddress = newAddress;
    notifyListeners();
  }

  // Update payment status
  void updatePaymentStatus(String status) {
    _paymentStatus = status;
    notifyListeners();
  }

// set delivery fee
  void setDeliveryFee(double fee) {
    _deliveryFee = fee;
    print('Restaurant - Set delivery fee: ${formatPrice(_deliveryFee)}');
    notifyListeners();
  }

  // Clear cart
  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}

// Cart item class
class CartItem {
  Food food;
  List<Addon> selectedAddons;
  int quantity;

  CartItem({
    required this.food,
    required this.selectedAddons,
    this.quantity = 1,
  });

  double get totalPrice {
    double addonsPrice =
        selectedAddons.fold(0, (sum, addon) => sum + addon.price);
    return (food.price + addonsPrice) * quantity;
  }
}
