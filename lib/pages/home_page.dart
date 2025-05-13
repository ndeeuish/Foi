import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:foi/components/my_current_location.dart';
import 'package:foi/components/my_description_box.dart';
import 'package:foi/components/my_drawer.dart';
import 'package:foi/components/my_food_tile.dart';
import 'package:foi/components/my_sliver_app_bar.dart';
import 'package:foi/components/my_tab_bar.dart';
import 'package:foi/models/food.dart';
import 'package:foi/models/restaurant.dart';
import 'package:foi/pages/food_page.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: FoodCategory.values.length, vsync: this);

    // Load menu data when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<Restaurant>(context, listen: false).loadMenu();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Filter menu by category
  List<Food> _filterMenuByCategory(FoodCategory category, List<Food> fullMenu) {
    return fullMenu.where((food) => food.category == category).toList();
  }

  // Generate widgets for each category tab
  List<Widget> getFoodInThisCategory(List<Food> fullMenu) {
    return FoodCategory.values.map((category) {
      List<Food> categoryMenu = _filterMenuByCategory(category, fullMenu);
      return AnimationLimiter(
        child: ListView.builder(
          controller: _scrollController,
          itemCount: categoryMenu.length,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemBuilder: (context, index) {
            final food = categoryMenu[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: FoodTile(
                    food: food,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FoodPage(food: food)),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }).toList();
  }

  // Shimmer loading indicator
  Widget _buildLoadingIndicator() {
    return ListView.builder(
      itemCount: 5,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  // Elegant error message
  Widget _buildErrorMessage(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade300,
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              'Oops! Something Went Wrong',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              style: TextStyle(
                fontSize: 16,
                color: Colors.red.shade400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Provider.of<Restaurant>(context, listen: false).loadMenu();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Loading Menu'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red.shade700,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Empty menu state
  Widget _buildEmptyMenuState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          Text(
            'No Dishes Available',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Our kitchen is preparing something special',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const MyDrawer(),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          MySliverAppBar(
            title: MyTabBar(tabController: _tabController),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Divider(
                    indent: 25,
                    endIndent: 25,
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.3),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current location input with improved styling
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Transform.translate(
                              offset: const Offset(16, 0),
                              child: const Icon(Icons.location_on,
                                  color: Colors.red, size: 20),
                            ),
                            MyCurrentLocation(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Consumer<Restaurant>(
                    builder: (context, restaurant, child) => MyDescriptionBox(
                      address: restaurant.deliveryAddress,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        body: Consumer<Restaurant>(
          builder: (context, restaurant, child) {
            if (restaurant.isLoading) {
              return _buildLoadingIndicator();
            }

            if (restaurant.error != null) {
              return _buildErrorMessage(restaurant.error!);
            }

            if (restaurant.menu.isEmpty) {
              return _buildEmptyMenuState();
            }

            return TabBarView(
              controller: _tabController,
              children: getFoodInThisCategory(restaurant.menu),
            );
          },
        ),
      ),
    );
  }
}
