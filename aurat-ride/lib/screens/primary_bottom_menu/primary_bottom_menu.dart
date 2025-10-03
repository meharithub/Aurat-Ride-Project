import 'package:aurat_ride/global_widgets/primary_local_svg.dart';
import 'package:aurat_ride/screens/chat/chat_screen/chat_screen.dart';
import 'package:aurat_ride/screens/complete_your_profile/complete_your_profile_screen/complete_your_profile_screen.dart';
import 'package:aurat_ride/screens/contact_us/contact_us_screen/contact_us_screen.dart';
import 'package:aurat_ride/screens/favourite/favourite_screen/favourite_screen.dart';
import 'package:aurat_ride/screens/home_screen_transport/components/primary_drawer.dart';
import 'package:aurat_ride/screens/home_screen_transport/home_screen_transport_screen/home_transport_screen.dart';
import 'package:aurat_ride/screens/home_screen_transport/ride_history/ride_history_screen/ride_history_screen.dart';
import 'package:aurat_ride/screens/offer/offer_screen/offer_screen.dart';
import 'package:aurat_ride/screens/settings/settings_screen/settings_screen.dart';
import 'package:aurat_ride/screens/payment/payment_screen/payment_screen.dart';
import 'package:aurat_ride/screens/emergency/emergency_screen/emergency_screen.dart';
import 'package:aurat_ride/screens/notifications/enhanced_notifications_screen/enhanced_notifications_screen.dart';
import 'package:aurat_ride/utlils/path/asset_paths.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:flutter/material.dart';

class PrimaryBottomSheet extends StatefulWidget {
  final bool isHome;
  const PrimaryBottomSheet({super.key, this.isHome = false});

  @override
  State<PrimaryBottomSheet> createState() => _PrimaryBottomSheetState();
}

class _PrimaryBottomSheetState extends State<PrimaryBottomSheet> {
  int _selectedIndex = 0;

  // List of pages
  final List<Widget> _pages = [
    RideBookingScreen(),           // Index 0 - Home
    RideHistoryScreen(),           // Index 1 - Ride History
    EnhancedNotificationsScreen(), // Index 2 - Notifications
    SettingsScreen(),              // Index 3 - Profile/Settings
  ];

  // final List<int> _hideBottomNavOn = [7]; // Don't hide

  @override
  @override
  Widget build(BuildContext context) {
    // bool showBottomNav = !_hideBottomNavOn.contains(_selectedIndex);

    return Scaffold(
      drawer: PrimaryDrawer(),
      resizeToAvoidBottomInset: false,
      body: _pages[_selectedIndex],
      backgroundColor: kPrimaryWhite,
      // Conditionally show bottom nav
      bottomNavigationBar: _buildBottomNav(),

      // Floating center button for elevated item
      // floatingActionButton: SizedBox(
      //   height: 70,
      //   width: 70,
      //   child: FloatingActionButton(
      //     onPressed: () {
      //       setState(() {
      //         _selectedIndex = 2;
      //       });
      //     },
      //     shape: const CircleBorder(),
      //     child: Padding(
      //       padding: const EdgeInsets.all(15.0),
      //       child:
      //           PrimaryLocalSvg(svgPath: "$kLocalImageBaseUrl/wallet-icon.svg"),
      //     ),
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      selectedItemColor: kPrimaryGreen,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      elevation: 8,
      items: [
        BottomNavigationBarItem(
          icon: PrimaryLocalSvg(
            svgPath: "$kLocalImageBaseUrl/home-icon.svg",
            color: _selectedIndex == 0 ? kPrimaryGreen : Colors.grey,
          ),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.history,
            color: _selectedIndex == 1 ? kPrimaryGreen : Colors.grey,
          ),
          label: "History",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.notifications,
            color: _selectedIndex == 2 ? kPrimaryGreen : Colors.grey,
          ),
          label: "Notifications",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.person,
            color: _selectedIndex == 3 ? kPrimaryGreen : Colors.grey,
          ),
          label: "Profile",
        ),
      ],
    );
  }

}
