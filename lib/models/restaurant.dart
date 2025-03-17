import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:foi/models/cart_item.dart';
import 'package:intl/intl.dart';

import 'food.dart';

class Restaurant extends ChangeNotifier {
  //list food menu
  final List<Food> _menu = [
    //burger
    Food(
      name: "Classic cheeseburger",
      description: "A beef patty with cheddar, lettuce, tomato and onion",
      imagePath: "lib/images/burgers/classic.png",
      price: 2.99,
      category: FoodCategory.burgers,
      availableAddons: [
        Addon(name: "Extra cheese", price: 0.99),
        Addon(name: "Bacon", price: 1.99),
        Addon(name: "Pickle", price: 1.99),
      ],
    ),

    Food(
      name: "Chicken Burger",
      description: "A crispy chicken patty with lettuce, mayo, and tomato",
      imagePath: "lib/images/burgers/chicken.png",
      price: 3.49,
      category: FoodCategory.burgers,
      availableAddons: [
        Addon(name: "Extra cheese", price: 0.99),
        Addon(name: "Bacon", price: 1.99),
        Addon(name: "Pickle", price: 1.99),
      ],
    ),

    Food(
      name: "BBQ Burger",
      description:
          "Smokey BBQ sauce, crispy bacon with lettuce, tomato, and onion",
      imagePath: "lib/images/burgers/beef.png",
      price: 3.99,
      category: FoodCategory.burgers,
      availableAddons: [
        Addon(name: "Extra cheese", price: 0.99),
        Addon(name: "Bacon", price: 1.99),
        Addon(name: "Pickle", price: 1.99),
      ],
    ),

    Food(
      name: "Shrimp Burger",
      description: "A crispy shrimp patty with tartar sauce and lettuce",
      imagePath: "lib/images/burgers/shrimp.png",
      price: 4.49,
      category: FoodCategory.burgers,
      availableAddons: [
        Addon(name: "Extra cheese", price: 0.99),
        Addon(name: "Bacon", price: 1.99),
        Addon(name: "Pickle", price: 1.99),
      ],
    ),

    Food(
      name: "Double Burger",
      description: "Two beef patties with cheddar, lettuce, tomato, and onion",
      imagePath: "lib/images/burgers/double.png",
      price: 5.99,
      category: FoodCategory.burgers,
      availableAddons: [
        Addon(name: "Extra cheese", price: 0.99),
        Addon(name: "Bacon", price: 1.99),
        Addon(name: "Pickle", price: 1.99),
      ],
    ),

    // salad
    Food(
      name: "Caesar Salad",
      description:
          "Fresh romaine lettuce with croutons, parmesan cheese, and Caesar dressing",
      imagePath: "lib/images/salads/caesar.png",
      price: 3.99,
      category: FoodCategory.salads,
      availableAddons: [
        Addon(name: "Grilled chicken", price: 1.99),
        Addon(name: "Extra parmesan", price: 0.99),
        Addon(name: "Bacon bits", price: 1.49),
      ],
    ),

    Food(
      name: "Chicken Salad",
      description:
          "Grilled chicken breast on a bed of mixed greens with cherry tomatoes and vinaigrette",
      imagePath: "lib/images/salads/chicken.png",
      price: 4.49,
      category: FoodCategory.salads,
      availableAddons: [
        Addon(name: "Extra chicken", price: 1.99),
        Addon(name: "Avocado", price: 1.49),
        Addon(name: "Feta cheese", price: 0.99),
      ],
    ),

    Food(
      name: "Mushroom Salad",
      description:
          "Sautéed mushrooms with spinach, arugula, and balsamic dressing",
      imagePath: "lib/images/salads/mushroom.png",
      price: 4.29,
      category: FoodCategory.salads,
      availableAddons: [
        Addon(name: "Grilled tofu", price: 1.49),
        Addon(name: "Walnuts", price: 1.29),
        Addon(name: "Goat cheese", price: 1.19),
      ],
    ),

    Food(
      name: "Spinach Salad",
      description:
          "Fresh baby spinach with sliced strawberries, almonds, and honey mustard dressing",
      imagePath: "lib/images/salads/spinach.png",
      price: 4.79,
      category: FoodCategory.salads,
      availableAddons: [
        Addon(name: "Blue cheese", price: 1.29),
        Addon(name: "Cranberries", price: 0.99),
        Addon(name: "Grilled chicken", price: 1.99),
      ],
    ),

    Food(
      name: "Shrimp Salad",
      description:
          "Grilled shrimp with mixed greens, avocado, and citrus vinaigrette",
      imagePath: "lib/images/salads/shrimp.png",
      price: 5.49,
      category: FoodCategory.salads,
      availableAddons: [
        Addon(name: "Extra shrimp", price: 2.49),
        Addon(name: "Mango slices", price: 1.29),
        Addon(name: "Cashews", price: 1.19),
      ],
    ),

    //sides
    Food(
      name: "French Fries",
      description: "Crispy golden fries with a side of ketchup",
      imagePath: "lib/images/sides/fries.png",
      price: 2.49,
      category: FoodCategory.sides,
      availableAddons: [
        Addon(name: "Cheese sauce", price: 0.99),
        Addon(name: "Bacon bits", price: 1.49),
        Addon(name: "Garlic butter", price: 0.99),
      ],
    ),

    Food(
      name: "Mac and Cheese",
      description: "Creamy macaroni with melted cheddar cheese",
      imagePath: "lib/images/sides/mac_cheese.png",
      price: 3.49,
      category: FoodCategory.sides,
      availableAddons: [
        Addon(name: "Extra cheese", price: 0.99),
        Addon(name: "Truffle oil", price: 1.99),
        Addon(name: "Bacon bits", price: 1.49),
      ],
    ),

    Food(
      name: "Onion Rings",
      description:
          "Crispy battered onion rings served with a tangy dipping sauce",
      imagePath: "lib/images/sides/onion_rings.png",
      price: 2.99,
      category: FoodCategory.sides,
      availableAddons: [
        Addon(name: "Spicy mayo", price: 0.99),
        Addon(name: "BBQ sauce", price: 0.99),
        Addon(name: "Extra crispy", price: 0.79),
      ],
    ),

    Food(
      name: "Egg",
      description: "Perfectly cooked egg, available fried or boiled",
      imagePath: "lib/images/sides/egg.png",
      price: 1.49,
      category: FoodCategory.sides,
      availableAddons: [
        Addon(name: "Double egg", price: 0.99),
        Addon(name: "Soy sauce", price: 0.49),
        Addon(name: "Chili flakes", price: 0.59),
      ],
    ),

    Food(
      name: "Chips",
      description: "Crunchy potato chips with a variety of flavors",
      imagePath: "lib/images/sides/chips.png",
      price: 2.29,
      category: FoodCategory.sides,
      availableAddons: [
        Addon(name: "Cheddar seasoning", price: 0.99),
        Addon(name: "Spicy seasoning", price: 0.99),
        Addon(name: "Ranch dip", price: 1.29),
      ],
    ),

    //drinks
    Food(
      name: "Beer",
      description: "Chilled refreshing beer, perfect for any meal",
      imagePath: "lib/images/drinks/beer.png",
      price: 3.99,
      category: FoodCategory.drinks,
      availableAddons: [
        Addon(name: "Extra cold", price: 0.49),
        Addon(name: "Lemon slice", price: 0.59),
        Addon(name: "Salt rim", price: 0.69),
      ],
    ),

    Food(
      name: "Fanta",
      description: "Fizzy orange soda with a sweet and tangy taste",
      imagePath: "lib/images/drinks/fanta.png",
      price: 1.99,
      category: FoodCategory.drinks,
      availableAddons: [
        Addon(name: "Extra ice", price: 0.29),
        Addon(name: "Lemon slice", price: 0.49),
        Addon(name: "Large size", price: 0.99),
      ],
    ),

    Food(
      name: "Iced Tea",
      description: "Refreshing iced tea with a hint of lemon",
      imagePath: "lib/images/drinks/icetea.png",
      price: 2.49,
      category: FoodCategory.drinks,
      availableAddons: [
        Addon(name: "Honey", price: 0.79),
        Addon(name: "Mint leaves", price: 0.59),
        Addon(name: "Extra lemon", price: 0.49),
      ],
    ),

    Food(
      name: "Coke",
      description: "Classic Coca-Cola with a bold and crisp taste",
      imagePath: "lib/images/drinks/coke.png",
      price: 1.99,
      category: FoodCategory.drinks,
      availableAddons: [
        Addon(name: "Extra ice", price: 0.29),
        Addon(name: "Lime wedge", price: 0.49),
        Addon(name: "Large size", price: 0.99),
      ],
    ),

    Food(
      name: "Water",
      description: "Pure and refreshing bottled water",
      imagePath: "lib/images/drinks/water.png",
      price: 1.49,
      category: FoodCategory.drinks,
      availableAddons: [
        Addon(name: "Chilled", price: 0.29),
        Addon(name: "Lemon slice", price: 0.49),
        Addon(name: "Sparkling upgrade", price: 0.99),
      ],
    ),

    //desserts
    Food(
      name: "Brownie",
      description: "Rich and fudgy chocolate brownie topped with walnuts",
      imagePath: "lib/images/desserts/brownie.png",
      price: 3.49,
      category: FoodCategory.desserts,
      availableAddons: [
        Addon(name: "Vanilla ice cream", price: 1.49),
        Addon(name: "Chocolate syrup", price: 0.99),
        Addon(name: "Extra walnuts", price: 0.79),
      ],
    ),

    Food(
      name: "Cake",
      description: "Soft and moist cake with layers of chocolate and nut",
      imagePath: "lib/images/desserts/cake.png",
      price: 4.29,
      category: FoodCategory.desserts,
      availableAddons: [
        Addon(name: "Extra cream", price: 0.99),
        Addon(name: "Berry topping", price: 1.49),
        Addon(name: "Chocolate shavings", price: 1.19),
      ],
    ),

    Food(
      name: "Lemon pie",
      description: "Lemon pie with layers of cream ",
      imagePath: "lib/images/desserts/pie.png",
      price: 2.99,
      category: FoodCategory.desserts,
      availableAddons: [
        Addon(name: "Chocolate chips", price: 0.99),
        Addon(name: "Caramel drizzle", price: 0.99),
        Addon(name: "Waffle cone", price: 0.79),
      ],
    ),

    Food(
      name: "Mousse",
      description: "Light and airy chocolate mousse with a rich texture",
      imagePath: "lib/images/desserts/mousse.png",
      price: 3.99,
      category: FoodCategory.desserts,
      availableAddons: [
        Addon(name: "Whipped cream", price: 0.99),
        Addon(name: "Cocoa powder", price: 0.79),
        Addon(name: "Raspberry sauce", price: 1.29),
      ],
    ),

    Food(
      name: "Macaron",
      description: "Delicate French macarons with a soft and chewy center",
      imagePath: "lib/images/desserts/macaron.png",
      price: 5.49,
      category: FoodCategory.desserts,
      availableAddons: [
        Addon(name: "Mixed flavors", price: 1.99),
        Addon(name: "Extra filling", price: 1.49),
        Addon(name: "Gold flakes", price: 2.49),
      ],
    ),
  ];

  //user cart
  final List<CartItem> _cart = [];

  //delivery address
  String _deliveryAddress = " LEu leu";
  /*

    G E T T E R S

    */

  List<Food> get menu => _menu;
  List<CartItem> get cart => _cart;
  String get deliveryAddress => _deliveryAddress;

  /*

    O P E R A T I O N S

    */
  // add to cart

  void addToCart(Food food, List<Addon> selectedAddons) {
    //see if there is a a cart item already with the same food and selected adđón
    CartItem? cartItem = _cart.firstWhereOrNull((item) {
      //check if the food item are the same
      bool isSameFood = item.food == food;
      //Check if the list of selected addons is the same
      bool isSameAddons =
          ListEquality().equals(item.selectedAddons, selectedAddons);
      return isSameFood && isSameAddons;
    });
    //if item already exists, increase it's quaity
    if (cartItem != null) {
      cartItem.quantity++;
    }
    //otherwise, add a new cart item to the cart
    else {
      _cart.add(
        CartItem(
          food: food,
          selectedAddons: selectedAddons,
        ),
      );
    }
    notifyListeners();
  }

  // remove from cart

  void removeFromCart(CartItem cartItem) {
    int cartIndex = _cart.indexOf(cartItem);
    if (cartIndex != -1) {
      if (_cart[cartIndex].quantity > 1) {
        _cart[cartIndex].quantity--;
      } else {
        _cart.removeAt(cartIndex);
      }
    }
    notifyListeners();
  }

  // get total price cart
  double getTotalPrice() {
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

  // get total number items cart
  int getTotalItemCount() {
    int totalItemCount = 0;
    for (CartItem cartItem in _cart) {
      totalItemCount += cartItem.quantity;
    }
    return totalItemCount;
  }

  // clear cart
  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  //update Delivery address
  void updateDeliveryAddress(String newAddress) {
    _deliveryAddress = newAddress;
    notifyListeners();
  }

  /* 

    H E P L E R S

  */
  // generate a receipt

  String displayCartReceipt() {
    final receipt = StringBuffer();
    receipt.writeln("Here is your receipt.");
    receipt.writeln();

    //format the date to includeup to seconds only
    String formattedDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    receipt.writeln(formattedDate);
    receipt.writeln();
    receipt.writeln("-----------");
    for (final cartItem in _cart) {
      receipt.writeln(
          "${cartItem.quantity} x ${cartItem.food.name} - ${_formatPrice(cartItem.food.price)}");
      if (cartItem.selectedAddons.isNotEmpty) {
        receipt
            .writeln("     Add-ons: ${_formatAddons(cartItem.selectedAddons)}");
      }
      receipt.writeln();
    }
    receipt.writeln("-----------");
    receipt.writeln();
    receipt.writeln("Total Items: ${getTotalItemCount()}");

    receipt.writeln("Total Price: ${_formatPrice(getTotalPrice())}");

    receipt.writeln();
    receipt.writeln("Delivery to: $deliveryAddress");

    return receipt.toString();
  }

  // format double value into money
  String _formatPrice(double price) {
    return "\$${price.toStringAsFixed(2)}";
  }

  // format list of addon into string summary
  String _formatAddons(List<Addon> addons) {
    return addons
        .map((addon) => "${addon.name} (${_formatPrice(addon.price)})")
        .join(", ");
  }
}
