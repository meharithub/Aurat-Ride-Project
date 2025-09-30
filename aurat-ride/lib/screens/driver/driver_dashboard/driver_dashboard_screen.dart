import 'package:aurat_ride/global_widgets/primary_heading.dart';
import 'package:aurat_ride/global_widgets/primary_local_svg.dart';
import 'package:aurat_ride/screens/auth_check/auth_check_screen.dart';
import 'package:aurat_ride/screens/driver/driver_profile/driver_profile_screen.dart';
import 'package:aurat_ride/screens/driver/driver_earnings/driver_earnings_screen.dart';
import 'package:aurat_ride/screens/driver/driver_ride_history/driver_ride_history_screen.dart';
import 'package:aurat_ride/screens/driver/driver_settings/driver_settings_screen.dart';
import 'package:aurat_ride/screens/driver/driver_ride_requests/driver_ride_requests_screen.dart';
import 'package:aurat_ride/services/user_service.dart';
import 'package:aurat_ride/services/api_service.dart';
import 'package:aurat_ride/utlils/helper_functions/helper_function.dart';
import 'package:aurat_ride/utlils/path/asset_paths.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:flutter/material.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  bool _isOnline = false;
  String _driverName = "Driver Name";
  double _earnings = 0.0;
  int _completedRides = 0;
  double _rating = 4.5;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await UserService.getUserData();
    setState(() {
      _driverName = userData['name'] ?? 'Driver Name';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryWhite,
      appBar: AppBar(
        backgroundColor: kPrimaryGreen,
        title: Text(
          'Driver Dashboard',
          style: TextStyle(color: kPrimaryWhite),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: kPrimaryWhite),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            _buildStatusCard(),
            SizedBox(height: 20),
            
            // Stats Cards
            Row(
              children: [
                Expanded(child: _buildStatCard('Earnings', 'Rs ${_earnings.toStringAsFixed(0)}', Icons.attach_money)),
                SizedBox(width: 10),
                Expanded(child: _buildStatCard('Rides', '$_completedRides', Icons.local_taxi)),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildStatCard('Rating', '${_rating.toStringAsFixed(1)} ⭐', Icons.star)),
                SizedBox(width: 10),
                Expanded(child: _buildStatCard('Status', _isOnline ? 'Online' : 'Offline', Icons.circle)),
              ],
            ),
            SizedBox(height: 20),
            
            // Quick Actions
            PrimaryHeading(
              heading: "Quick Actions",
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 10),
            _buildQuickActions(),
            SizedBox(height: 20),
            
            // Recent Rides
            PrimaryHeading(
              heading: "Recent Rides",
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 10),
            _buildRecentRides(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isOnline ? kPrimaryGreen : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: kPrimaryWhite,
            child: Icon(
              Icons.person,
              size: 30,
              color: _isOnline ? kPrimaryGreen : Colors.grey,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $_driverName',
                  style: TextStyle(
                    color: kPrimaryWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  _isOnline ? 'You are online and ready for rides' : 'You are offline',
                  style: TextStyle(
                    color: kPrimaryWhite,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isOnline,
            onChanged: (value) {
              setState(() {
                _isOnline = value;
              });
              _handleStatusChange(value);
            },
            activeColor: kPrimaryWhite,
            activeTrackColor: Colors.white70,
            inactiveThumbColor: Colors.grey[600],
            inactiveTrackColor: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kPrimaryWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: kPrimaryGreen, size: 30),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kPrimaryGreen,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'View Profile',
                Icons.person_outline,
                () => _navigateToProfile(),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _buildActionButton(
                'Earnings',
                Icons.attach_money,
                () => _navigateToEarnings(),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Ride Requests',
                Icons.directions_car,
                () => _navigateToRideRequests(),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _buildActionButton(
                'Ride History',
                Icons.history,
                () => _navigateToRideHistory(),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Settings',
                Icons.settings,
                () => _navigateToSettings(),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Container(), // Empty space for alignment
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kPrimaryWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kPrimaryGreen.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: kPrimaryGreen, size: 30),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: kPrimaryGreen,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRides() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kPrimaryWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildRideItem('Clifton to DHA', 'Rs 250', '4.5', '2 hours ago'),
          Divider(),
          _buildRideItem('Gulshan to Saddar', 'Rs 180', '5.0', '5 hours ago'),
          Divider(),
          _buildRideItem('Korangi to North Nazimabad', 'Rs 320', '4.0', '1 day ago'),
        ],
      ),
    );
  }

  Widget _buildRideItem(String route, String fare, String rating, String time) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                fare,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryGreen,
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber),
                  SizedBox(width: 4),
                  Text(
                    rating,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleStatusChange(bool isOnline) {
    _updateDriverStatus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isOnline ? 'You are now online' : 'You are now offline'),
      ),
    );
  }

  /// Update driver status via API
  Future<void> _updateDriverStatus() async {
    final userData = await UserService.getUserData();
    final token = userData['token'];
    
    if (token == null) return;

    try {
      final response = await ApiService.setDriverOnline(
        token: token,
        isOnline: _isOnline,
      );

      if (!response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: ${response['error']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: ${e.toString()}')),
      );
    }
  }

  void _navigateToProfile() {
    HelperFunctions.navigateTo(context, DriverProfileScreen());
  }

  void _navigateToEarnings() {
    HelperFunctions.navigateTo(context, DriverEarningsScreen());
  }

  void _navigateToRideRequests() {
    HelperFunctions.navigateTo(context, DriverRideRequestsScreen());
  }

  void _navigateToRideHistory() {
    HelperFunctions.navigateTo(context, DriverRideHistoryScreen());
  }

  void _navigateToSettings() {
    HelperFunctions.navigateTo(context, DriverSettingsScreen());
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await UserService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => AuthCheckScreen()),
                (route) => false,
              );
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}
