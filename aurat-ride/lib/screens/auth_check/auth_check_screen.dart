import 'package:aurat_ride/screens/driver/driver_dashboard/driver_dashboard_screen.dart';
import 'package:aurat_ride/screens/login/login_screen/login_screen.dart';
import 'package:aurat_ride/screens/primary_bottom_menu/primary_bottom_menu.dart';
import 'package:aurat_ride/screens/admin/admin_dashboard_screen.dart';
import 'package:aurat_ride/services/user_service.dart';
import 'package:flutter/material.dart';

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Add a small delay to show loading
    await Future.delayed(Duration(seconds: 1));
    
    if (mounted) {
      final isLoggedIn = await UserService.isLoggedIn();
      
      if (isLoggedIn) {
        final isAdmin = await UserService.isAdmin();
        final isDriver = await UserService.isDriver();
        
        if (isAdmin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
          );
        } else if (isDriver) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DriverDashboardScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PrimaryBottomSheet()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Color(0xff008955),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.local_taxi,
                size: 60,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 30),
            
            // App Name
            Text(
              'Aurat Ride',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xff008955),
              ),
            ),
            SizedBox(height: 10),
            
            Text(
              'Your Safe Ride Partner',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 40),
            
            // Loading Indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xff008955)),
            ),
            SizedBox(height: 20),
            
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
