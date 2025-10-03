import 'package:flutter/material.dart';
import 'package:aurat_ride/services/api_service.dart';
import 'package:aurat_ride/services/user_service.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:aurat_ride/utlils/helper_functions/helper_function.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  Map<String, dynamic> settings = {};
  bool isLoading = true;
  String? error;
  bool isSaving = false;
  
  final Map<String, TextEditingController> controllers = {};
  final Map<String, bool> booleanValues = {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final token = await UserService.getToken();
      if (token == null) {
        setState(() {
          error = 'No authentication token found';
          isLoading = false;
        });
        return;
      }

      final response = await ApiService.getAdminSettings(token);
      
      if (response['status'] == true) {
        setState(() {
          settings = response['data'];
          _initializeControllers();
          isLoading = false;
        });
      } else {
        setState(() {
          error = response['message'] ?? 'Failed to load settings';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error loading settings: $e';
        isLoading = false;
      });
    }
  }

  void _initializeControllers() {
    for (var entry in settings.entries) {
      final key = entry.key;
      final value = entry.value;
      
      if (value is Map<String, dynamic>) {
        final settingValue = value['value'];
        if (settingValue is String) {
          controllers[key] = TextEditingController(text: settingValue);
        } else if (settingValue is bool) {
          booleanValues[key] = settingValue;
        }
      }
    }
  }

  Future<void> _saveSettings() async {
    try {
      setState(() {
        isSaving = true;
      });

      final token = await UserService.getToken();
      if (token == null) return;

      final Map<String, dynamic> updatedSettings = {};
      
      // Add text field values
      for (var entry in controllers.entries) {
        updatedSettings[entry.key] = entry.value.text;
      }
      
      // Add boolean values
      for (var entry in booleanValues.entries) {
        updatedSettings[entry.key] = entry.value;
      }

      final response = await ApiService.updateAdminSettings(
        token: token,
        settings: updatedSettings,
      );

      if (response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully')),
        );
        _loadSettings();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to save settings')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving settings: $e')),
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryWhite,
      appBar: AppBar(
        title: const Text(
          'App Settings',
          style: TextStyle(
            color: kPrimaryWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: kPrimaryGreen,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: kPrimaryWhite),
            onPressed: _loadSettings,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        error!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadSettings,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSettings,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFareSettings(),
                        const SizedBox(height: 24),
                        _buildAppSettings(),
                        const SizedBox(height: 24),
                        _buildSupportSettings(),
                        const SizedBox(height: 24),
                        _buildSaveButton(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildFareSettings() {
    return _buildSettingsSection(
      'Fare Settings',
      Icons.attach_money,
      [
        _buildTextFieldSetting('base_fare', 'Base Fare (Rs.)', 'Base fare for rides'),
        _buildTextFieldSetting('per_km_rate', 'Per KM Rate (Rs.)', 'Rate per kilometer'),
        _buildTextFieldSetting('per_minute_rate', 'Per Minute Rate (Rs.)', 'Rate per minute'),
        _buildTextFieldSetting('minimum_fare', 'Minimum Fare (Rs.)', 'Minimum fare for rides'),
        _buildTextFieldSetting('maximum_fare', 'Maximum Fare (Rs.)', 'Maximum fare for rides'),
        _buildTextFieldSetting('driver_commission_percentage', 'Driver Commission (%)', 'Percentage commission for drivers'),
      ],
    );
  }

  Widget _buildAppSettings() {
    return _buildSettingsSection(
      'App Settings',
      Icons.settings,
      [
        _buildTextFieldSetting('app_version', 'App Version', 'Current app version'),
        _buildBooleanSetting('maintenance_mode', 'Maintenance Mode', 'Enable maintenance mode'),
      ],
    );
  }

  Widget _buildSupportSettings() {
    return _buildSettingsSection(
      'Support Settings',
      Icons.support_agent,
      [
        _buildTextFieldSetting('support_email', 'Support Email', 'Support contact email'),
        _buildTextFieldSetting('support_phone', 'Support Phone', 'Support contact phone'),
      ],
    );
  }

  Widget _buildSettingsSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: kPrimaryGreen, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextFieldSetting(String key, String label, String hint) {
    final controller = controllers[key];
    if (controller == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          suffixText: _getSuffixText(key),
        ),
        keyboardType: _getKeyboardType(key),
      ),
    );
  }

  Widget _buildBooleanSetting(String key, String label, String hint) {
    final value = booleanValues[key] ?? false;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SwitchListTile(
        title: Text(label),
        subtitle: Text(hint),
        value: value,
        onChanged: (newValue) {
          setState(() {
            booleanValues[key] = newValue;
          });
        },
        activeColor: kPrimaryGreen,
      ),
    );
  }

  TextInputType _getKeyboardType(String key) {
    switch (key) {
      case 'base_fare':
      case 'per_km_rate':
      case 'per_minute_rate':
      case 'minimum_fare':
      case 'maximum_fare':
      case 'driver_commission_percentage':
        return TextInputType.number;
      case 'support_email':
        return TextInputType.emailAddress;
      case 'support_phone':
        return TextInputType.phone;
      default:
        return TextInputType.text;
    }
  }

  String? _getSuffixText(String key) {
    switch (key) {
      case 'base_fare':
      case 'per_km_rate':
      case 'per_minute_rate':
      case 'minimum_fare':
      case 'maximum_fare':
        return 'Rs.';
      case 'driver_commission_percentage':
        return '%';
      default:
        return null;
    }
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSaving ? null : _saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isSaving
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Saving...'),
                ],
              )
            : const Text(
                'Save Settings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
