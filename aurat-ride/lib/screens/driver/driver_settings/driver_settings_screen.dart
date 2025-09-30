import 'package:aurat_ride/global_widgets/primary_back_button.dart';
import 'package:aurat_ride/global_widgets/primary_heading.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:flutter/material.dart';

class DriverSettingsScreen extends StatefulWidget {
  const DriverSettingsScreen({super.key});

  @override
  State<DriverSettingsScreen> createState() => _DriverSettingsScreenState();
}

class _DriverSettingsScreenState extends State<DriverSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationSharingEnabled = true;
  bool _autoAcceptRides = false;
  double _maxDistance = 10.0;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryWhite,
      appBar: AppBar(
        backgroundColor: kPrimaryGreen,
        title: Text(
          'Settings',
          style: TextStyle(color: kPrimaryWhite),
        ),
        leading: PrimaryBackButton(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Settings
            PrimaryHeading(
              heading: "Account Settings",
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 10),
            _buildAccountSettings(),
            SizedBox(height: 20),
            
            // Ride Settings
            PrimaryHeading(
              heading: "Ride Settings",
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 10),
            _buildRideSettings(),
            SizedBox(height: 20),
            
            // App Settings
            PrimaryHeading(
              heading: "App Settings",
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 10),
            _buildAppSettings(),
            SizedBox(height: 20),
            
            // Support
            PrimaryHeading(
              heading: "Support",
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 10),
            _buildSupportSettings(),
            SizedBox(height: 20),
            
            // Logout Button
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Container(
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
          _buildSettingItem(
            'Edit Profile',
            'Update your personal information',
            Icons.person_outline,
            () => _navigateToProfile(),
          ),
          Divider(height: 1),
          _buildSettingItem(
            'Change Password',
            'Update your password',
            Icons.lock_outline,
            () => _changePassword(),
          ),
          Divider(height: 1),
          _buildSettingItem(
            'Bank Account',
            'Manage your bank details',
            Icons.account_balance,
            () => _manageBankAccount(),
          ),
        ],
      ),
    );
  }

  Widget _buildRideSettings() {
    return Container(
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
          _buildSwitchItem(
            'Auto Accept Rides',
            'Automatically accept nearby ride requests',
            _autoAcceptRides,
            (value) => setState(() => _autoAcceptRides = value),
            Icons.auto_awesome,
          ),
          Divider(height: 1),
          _buildSliderItem(
            'Maximum Distance',
            'Max distance for ride requests (${_maxDistance.toStringAsFixed(1)} km)',
            _maxDistance,
            (value) => setState(() => _maxDistance = value),
            Icons.straighten,
            1.0,
            50.0,
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettings() {
    return Container(
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
          _buildSwitchItem(
            'Push Notifications',
            'Receive ride requests and updates',
            _notificationsEnabled,
            (value) => setState(() => _notificationsEnabled = value),
            Icons.notifications_outlined,
          ),
          Divider(height: 1),
          _buildSwitchItem(
            'Location Sharing',
            'Share your location for better matching',
            _locationSharingEnabled,
            (value) => setState(() => _locationSharingEnabled = value),
            Icons.location_on_outlined,
          ),
          Divider(height: 1),
          _buildDropdownItem(
            'Language',
            'Select your preferred language',
            _selectedLanguage,
            ['English', 'Urdu', 'Arabic'],
            (value) => setState(() => _selectedLanguage = value!),
            Icons.language,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSettings() {
    return Container(
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
          _buildSettingItem(
            'Help Center',
            'Get help and support',
            Icons.help_outline,
            () => _openHelpCenter(),
          ),
          Divider(height: 1),
          _buildSettingItem(
            'Contact Support',
            'Get in touch with our support team',
            Icons.support_agent,
            () => _contactSupport(),
          ),
          Divider(height: 1),
          _buildSettingItem(
            'Terms & Conditions',
            'View terms and conditions',
            Icons.description_outlined,
            () => _viewTerms(),
          ),
          Divider(height: 1),
          _buildSettingItem(
            'Privacy Policy',
            'View privacy policy',
            Icons.privacy_tip_outlined,
            () => _viewPrivacyPolicy(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: kPrimaryGreen),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  Widget _buildSwitchItem(String title, String subtitle, bool value, ValueChanged<bool> onChanged, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: kPrimaryGreen),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: kPrimaryGreen,
      ),
    );
  }

  Widget _buildSliderItem(String title, String subtitle, double value, ValueChanged<double> onChanged, IconData icon, double min, double max) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: kPrimaryGreen),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) * 10).round(),
            activeColor: kPrimaryGreen,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownItem(String title, String subtitle, String value, List<String> items, ValueChanged<String?> onChanged, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: kPrimaryGreen),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        underline: SizedBox(),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 20),
      child: ElevatedButton(
        onPressed: _handleLogout,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: kPrimaryWhite,
          ),
        ),
      ),
    );
  }

  void _navigateToProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile screen coming soon')),
    );
  }

  void _changePassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Change password coming soon')),
    );
  }

  void _manageBankAccount() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bank account management coming soon')),
    );
  }

  void _openHelpCenter() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Help center coming soon')),
    );
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Contact support coming soon')),
    );
  }

  void _viewTerms() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Terms & conditions coming soon')),
    );
  }

  void _viewPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Privacy policy coming soon')),
    );
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
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement logout logic
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Logged out successfully')),
              );
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}
