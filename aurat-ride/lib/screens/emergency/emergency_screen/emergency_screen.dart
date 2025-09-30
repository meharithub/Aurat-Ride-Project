import 'dart:async';
import 'package:aurat_ride/services/api_service.dart';
import 'package:aurat_ride/services/user_service.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:aurat_ride/utlils/helper_functions/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  String? _userToken;
  Position? _currentPosition;
  bool _isLoading = false;
  bool _sosSent = false;
  Timer? _countdownTimer;
  int _countdown = 5;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userData = await UserService.getUserData();
    setState(() {
      _userToken = userData['token'];
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          'Emergency & Safety',
          style: TextStyle(color: kPrimaryWhite),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kPrimaryWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency SOS Section
            _buildEmergencySOSSection(),
            SizedBox(height: 24),
            
            // Safety Report Section
            _buildSafetyReportSection(),
            SizedBox(height: 24),
            
            // Emergency Contacts
            _buildEmergencyContacts(),
            SizedBox(height: 24),
            
            // Safety Tips
            _buildSafetyTips(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencySOSSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text(
                'Emergency SOS',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Send an emergency alert with your location to emergency contacts and nearby drivers.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red[700],
            ),
          ),
          SizedBox(height: 16),
          if (_sosSent)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Emergency SOS sent successfully! Help is on the way.',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _currentPosition != null && _userToken != null
                    ? _sendEmergencySOS
                    : null,
                icon: Icon(Icons.sos, size: 24),
                label: Text(
                  _isLoading ? 'Sending...' : 'Send Emergency SOS',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: kPrimaryWhite,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          if (_countdown > 0 && _countdown < 5)
            SizedBox(height: 12),
          if (_countdown > 0 && _countdown < 5)
            Text(
              'Sending in $_countdown seconds...',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSafetyReportSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.report_problem, color: Colors.orange[700], size: 28),
              SizedBox(width: 12),
              Text(
                'Report Safety Issue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Report any safety concerns during your ride.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.orange[700],
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showSafetyReportDialog,
              icon: Icon(Icons.report),
              label: Text('Report Issue'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: kPrimaryWhite,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContacts() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.contacts, color: Colors.blue[700], size: 28),
              SizedBox(width: 12),
              Text(
                'Emergency Contacts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildContactItem('Police', '15', Icons.local_police),
          _buildContactItem('Ambulance', '115', Icons.medical_services),
          _buildContactItem('Fire Department', '16', Icons.local_fire_department),
          _buildContactItem('Women Helpline', '1091', Icons.woman),
        ],
      ),
    );
  }

  Widget _buildContactItem(String name, String number, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[700], size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            number,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.phone, color: Colors.blue[700], size: 20),
            onPressed: () {
              // In production, implement phone call
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling $name...')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyTips() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates, color: Colors.green[700], size: 28),
              SizedBox(width: 12),
              Text(
                'Safety Tips',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildSafetyTip('Always verify driver details before getting in the car'),
          _buildSafetyTip('Share your ride details with a trusted contact'),
          _buildSafetyTip('Trust your instincts - if something feels wrong, cancel the ride'),
          _buildSafetyTip('Keep your phone charged and accessible during rides'),
          _buildSafetyTip('Use the in-app emergency features if needed'),
        ],
      ),
    );
  }

  Widget _buildSafetyTip(String tip) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.green[600], size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 14,
                color: Colors.green[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendEmergencySOS() {
    if (_currentPosition == null || _userToken == null) return;

    setState(() {
      _isLoading = true;
    });

    // Start countdown
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
      });

      if (_countdown <= 0) {
        timer.cancel();
        _actuallySendSOS();
      }
    });
  }

  Future<void> _actuallySendSOS() async {
    try {
      final response = await ApiService.sendEmergencySOS(
        token: _userToken!,
        lat: _currentPosition!.latitude,
        lng: _currentPosition!.longitude,
        message: 'Emergency SOS sent from Aurat Ride app',
      );

      setState(() {
        _isLoading = false;
        _sosSent = response['success'];
      });

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Emergency SOS sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send SOS: ${response['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending SOS: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSafetyReportDialog() {
    final issueTypeController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedIssueType = 'driver_behavior';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Report Safety Issue'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedIssueType,
                decoration: InputDecoration(labelText: 'Issue Type'),
                items: [
                  DropdownMenuItem(value: 'driver_behavior', child: Text('Driver Behavior')),
                  DropdownMenuItem(value: 'vehicle_condition', child: Text('Vehicle Condition')),
                  DropdownMenuItem(value: 'route_issue', child: Text('Route Issue')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedIssueType = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Please describe the issue...',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _submitSafetyReport(selectedIssueType, descriptionController.text);
              },
              child: Text('Submit Report'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitSafetyReport(String issueType, String description) async {
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide a description')),
      );
      return;
    }

    try {
      final response = await ApiService.reportSafetyIssue(
        token: _userToken!,
        rideId: '1', // In production, get current ride ID
        issueType: issueType,
        description: description,
      );

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Safety report submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit report: ${response['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting report: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
