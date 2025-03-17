import 'package:flutter/material.dart';
import 'package:foi/auth/services/auth_service.dart';
import 'package:foi/auth/services/login_or_register.dart';
import 'package:foi/components/my_drawer_tile.dart';
import 'package:foi/pages/settings_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});
  void logout(BuildContext context) {
    final authService = AuthService();
    authService.signOut().then((_) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginOrRegister()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          //logo
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: Icon(
              Icons.lock_open_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Divider(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),

          //home list title
          MyDrawerTile(
            text: "H O M E",
            icon: Icons.home,
            onTap: () => Navigator.pop(context),
          ),

          //profile
          MyDrawerTile(
            text: "P R O F I L E",
            icon: Icons.person,
            onTap: () {
              Navigator.pop(context);
            },
          ),

          //setting list title
          MyDrawerTile(
            text: "S E T T I N G S",
            icon: Icons.settings,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsPage()));
            },
          ),

          const Spacer(),
          //logout list title
          MyDrawerTile(
            text: "L O G O U T",
            icon: Icons.logout,
            onTap: () {
              logout(context);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }
}
