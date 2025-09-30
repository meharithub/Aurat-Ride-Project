import 'package:aurat_ride/screens/login/login_screen/login_screen.dart';
import 'package:aurat_ride/screens/ride_history/ride_history_screen/ride_history_screen.dart';
import 'package:aurat_ride/screens/settings/settings_screen/settings_screen.dart';
import 'package:aurat_ride/utlils/helper_functions/helper_function.dart';
import 'package:flutter/material.dart';

class PrimaryDrawer extends StatelessWidget {
  const PrimaryDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: const [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage("assets/images/profile.png"), // replace with NetworkImage if needed
                  ),
                  SizedBox(height: 12),
                  Text(
                    "John Doe",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "+1 234 567 890",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // const Divider(thickness: 1, color: Colors.black12),

            // Menu items
            Expanded(
              child: ListView(
                children: [
                  _buildMenuItem(
                    icon: Icons.home,
                    text: "Home",
                    onTap: () {
                      HelperFunctions.navigateBack(context);
                    },
                  ),
                  _separator(),
                  _buildMenuItem(
                    icon: Icons.history,
                    text: "Ride History",
                    onTap: () {
                      HelperFunctions.navigateTo(context, RideHistoryScreen());
                    },
                  ),
                  _separator(),
                  _buildMenuItem(
                    icon: Icons.payment,
                    text: "Payments",
                    onTap: () {},
                  ),
                  _separator(),
                  _buildMenuItem(
                    icon: Icons.settings,
                    text: "Settings",
                    onTap: () {
                      HelperFunctions.navigateTo(context, SettingsScreen());
                    },
                  ),
                ],
              ),
            ),

            // Logout at bottom
            Column(
              children: [
                const Divider(thickness: 1, color: Colors.black12),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    HelperFunctions.navigateTo(context, LoginScreen());
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
      onTap: onTap,
    );
  }

  Widget _separator() {
    return const Divider(thickness: 1, color: Colors.black12, height: 0);
  }
}
