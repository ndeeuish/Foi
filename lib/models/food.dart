// food item
class Food {
  final String name;
  final String description;
  final String imagePath;
  final double price;
  final FoodCategory category;
  List<Addon> availableAddons;

  Food({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.price,
    required this.category,
    required this.availableAddons,
  });
}

// categories
enum FoodCategory {
  burgers,
  salads,
  desserts,
  sides,
  drinks,
}

// food addons
class Addon {
  String name;
  double price;

  Addon({required this.name, required this.price});
}
