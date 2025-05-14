import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foi/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:foi/services/auth_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    // _checkAdminRole();
  }

  // Future<void> _checkAdminRole() async {
  //   // final hasAdminRole = await isAdmin();
  //   setState(() {
  //     _isAdmin = hasAdminRole;
  //   });
  // }

  // Future<void> _seedData(BuildContext context) async {
  //   try {
  //     // final seedData = SeedData();
  //     // await seedData.seedFoodData();
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Successfully seeded sample data'),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Error seeding data: $e'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(left: 25, top: 10, right: 25),
            padding: const EdgeInsets.all(25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //darkmode
                Text(
                  "Dark Mode",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),

                //switch theme
                CupertinoSwitch(
                  value: Provider.of<ThemeProvider>(context, listen: false)
                      .isDarkMode,
                  onChanged: (value) =>
                      Provider.of<ThemeProvider>(context, listen: false)
                          .toggleTheme(),
                ),
              ],
            ),
          ),
          // if (_isAdmin)
          //   ListTile(
          //     leading: const Icon(Icons.data_array),
          //     title: const Text('Seed Sample Data'),
          //     subtitle: const Text('Add sample food items to the database'),
          //     onTap: () => _seedData(context),
          //   ),
        ],
      ),
    );
  }
}
