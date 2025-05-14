import 'package:flutter/foundation.dart';
import 'package:foi/models/food.dart';
import 'package:foi/services/firebase_service.dart';
import 'package:foi/auth/services/auth_service.dart';
import 'package:foi/auth/database/firestore.dart';
import 'package:intl/intl.dart';

class Restaurant extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  List<Food> _menu = [];
  bool _isLoading = false;
  String? _error;

  // User cart
  final List<CartItem> _cart = [];

  // Delivery address
  String _deliveryAddress = "";

  // Payment status
  String _paymentStatus = "Pending";

  // Delivery fee (kept for future use)
  double _deliveryFee = 0;

  // Estimated delivery time (kept for future use)
  String _estimatedTime = "0";

  // Voucher code and discount amount
  String? _voucherCode;
  double _discountAmount = 0.0;

  // Constructor
  Restaurant() {
    _initializeUserAddress();
  }

  // Initialize user address from profile
  Future<void> _initializeUserAddress() async {
    try {
      final user = _authService.getCurrentUser();
      if (user != null) {
        final profile = await _firestoreService.getUserProfile(user.uid);
        if (profile != null &&
            profile['address'] != null &&
            profile['address'].toString().isNotEmpty) {
          _deliveryAddress = profile['address'];
          print(
              'Restaurant - Loaded user address from profile: $_deliveryAddress');
        } else {
          print('Restaurant - No address found in user profile');
          _deliveryAddress = "";
        }
        notifyListeners();
      }
    } catch (e) {
      print('Restaurant - Error initializing user address: $e');
      _deliveryAddress = "";
      notifyListeners();
    }
  }

  // Getters
  List<Food> get menu => _menu;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<CartItem> get cart => _cart;
  String get deliveryAddress => _deliveryAddress;
  String get paymentStatus => _paymentStatus;
  double get deliveryFee => _deliveryFee;
  String get estimatedTime => _estimatedTime;
  String? get voucherCode => _voucherCode;
  double get discountAmount => _discountAmount;

  // Initialize and load data
  Future<void> loadMenu() async {
    print('Restaurant - Starting to load menu');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _menu = await _firebaseService.getFoodItems();
      print('Restaurant - Successfully loaded ${_menu.length} food items');
    } catch (e) {
      _error = 'Failed to load menu: $e';
      print('Restaurant - Error loading menu: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get food items by category
  List<Food> getFoodByCategory(FoodCategory category) {
    return _menu.where((food) => food.category == category).toList();
  }

  // Get food items by name
  List<Food> searchFood(String query) {
    return _menu
        .where((food) =>
            food.name.toLowerCase().contains(query.toLowerCase()) ||
            food.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Add new food item
  Future<void> addFoodItem(Food food) async {
    try {
      await _firebaseService.addFoodItem(food);
      await loadMenu(); // Reload the menu after adding
    } catch (e) {
      _error = 'Failed to add food item: $e';
      notifyListeners();
    }
  }

  // Update food item
  Future<void> updateFoodItem(String id, Food food) async {
    try {
      await _firebaseService.updateFoodItem(id, food);
      await loadMenu(); // Reload the menu after updating
    } catch (e) {
      _error = 'Failed to update food item: $e';
      notifyListeners();
    }
  }

  // Delete food item
  Future<void> deleteFoodItem(String id) async {
    try {
      await _firebaseService.deleteFoodItem(id);
      await loadMenu(); // Reload the menu after deleting
    } catch (e) {
      _error = 'Failed to delete food item: $e';
      notifyListeners();
    }
  }

  // Get food items by price range
  List<Food> getFoodByPriceRange(double minPrice, double maxPrice) {
    return _menu
        .where((food) => food.price >= minPrice && food.price <= maxPrice)
        .toList();
  }

  // Get food items by addon
  List<Food> getFoodByAddon(String addonName) {
    return _menu
        .where((food) => food.availableAddons.any((addon) =>
            addon.name.toLowerCase().contains(addonName.toLowerCase())))
        .toList();
  }

  // Get food items by price
  List<Food> getFoodByPrice(double price) {
    return _menu.where((food) => food.price == price).toList();
  }

  // Get food items by name
  List<Food> getFoodByName(String name) {
    return _menu
        .where((food) => food.name.toLowerCase().contains(name.toLowerCase()))
        .toList();
  }

  // Get food items by description
  List<Food> getFoodByDescription(String description) {
    return _menu
        .where((food) =>
            food.description.toLowerCase().contains(description.toLowerCase()))
        .toList();
  }

  // Get food items by image path
  List<Food> getFoodByImagePath(String imagePath) {
    return _menu
        .where((food) =>
            food.imagePath.toLowerCase().contains(imagePath.toLowerCase()))
        .toList();
  }

  // Get food items by category and price range
  List<Food> getFoodByCategoryAndPriceRange(
      FoodCategory category, double minPrice, double maxPrice) {
    return _menu
        .where((food) =>
            food.category == category &&
            food.price >= minPrice &&
            food.price <= maxPrice)
        .toList();
  }

  // Get food items by category and addon
  List<Food> getFoodByCategoryAndAddon(
      FoodCategory category, String addonName) {
    return _menu
        .where((food) =>
            food.category == category &&
            food.availableAddons.any((addon) =>
                addon.name.toLowerCase().contains(addonName.toLowerCase())))
        .toList();
  }

  // Get food items by category and price
  List<Food> getFoodByCategoryAndPrice(FoodCategory category, double price) {
    return _menu
        .where((food) => food.category == category && food.price == price)
        .toList();
  }

  // Get food items by category and name
  List<Food> getFoodByCategoryAndName(FoodCategory category, String name) {
    return _menu
        .where((food) =>
            food.category == category &&
            food.name.toLowerCase().contains(name.toLowerCase()))
        .toList();
  }

  // Get food items by category and description
  List<Food> getFoodByCategoryAndDescription(
      FoodCategory category, String description) {
    return _menu
        .where((food) =>
            food.category == category &&
            food.description.toLowerCase().contains(description.toLowerCase()))
        .toList();
  }

  // Get food items by category and image path
  List<Food> getFoodByCategoryAndImagePath(
      FoodCategory category, String imagePath) {
    return _menu
        .where((food) =>
            food.category == category &&
            food.imagePath.toLowerCase().contains(imagePath.toLowerCase()))
        .toList();
  }

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
    final existingIndex = _cart.indexWhere((item) =>
        item.food == food && listEquals(item.selectedAddons, selectedAddons));

    if (existingIndex >= 0) {
      _cart[existingIndex].quantity++;
    } else {
      _cart.add(CartItem(
        food: food,
        selectedAddons: selectedAddons,
        quantity: 1,
      ));
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
      // Clear voucher when cart changes
      clearVoucher();
      notifyListeners();
    }
  }

  // Calculate base price (cart items + addons)
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

  // Calculate total price (base - discount)
  double getTotalPrice() {
    double basePrice = getBasePrice();
    double total = basePrice - _discountAmount + deliveryFee * 1000;
    return total < 0 ? 0 : total;
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
    if (_voucherCode != null) {
      receipt.writeln("Voucher Applied: $_voucherCode");
      receipt.writeln("Discount: ${formatPrice(_discountAmount)}");
    }
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

  // Set estimated delivery time (kept for future)
  void setEstimatedTime(String time) {
    _estimatedTime = time;
    print('Restaurant - Set estimated time: $_estimatedTime');
    notifyListeners();
  }

  // Set delivery fee (kept for future)
  void setDeliveryFee(double fee) {
    _deliveryFee = fee;
    print('Restaurant - Set delivery fee: ${formatPrice(_deliveryFee)}');
    notifyListeners();
  }

  // Apply voucher
  void applyVoucher(String code, double discount) {
    _voucherCode = code;
    _discountAmount = discount;
    print(
        'Restaurant - Applied voucher "$code": Discount = ${formatPrice(discount)}');
    notifyListeners();
  }

  // Clear voucher
  void clearVoucher() {
    _voucherCode = null;
    _discountAmount = 0.0;
    print('Restaurant - Cleared voucher');
    notifyListeners();
  }

  // Clear cart
  void clearCart() {
    _cart.clear();
    clearVoucher();
    notifyListeners();
  }

  // Reset delivery address
  void resetDeliveryAddress() {
    _deliveryAddress = "";
    notifyListeners();
    print('Restaurant - Delivery address reset');
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
