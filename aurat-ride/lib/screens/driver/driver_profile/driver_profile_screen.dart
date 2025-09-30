import 'package:aurat_ride/global_widgets/primary_back_button.dart';
import 'package:aurat_ride/global_widgets/primary_button.dart';
import 'package:aurat_ride/global_widgets/primary_heading.dart';
import 'package:aurat_ride/global_widgets/primary_textfield.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:flutter/material.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _vehicleModelController = TextEditingController();
  final TextEditingController _vehicleNumberController = TextEditingController();
  
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDriverData();
  }

  void _loadDriverData() {
    // TODO: Load driver data from API
    _nameController.text = "Ahmed Ali";
    _emailController.text = "ahmed.ali@example.com";
    _phoneController.text = "+92 300 1234567";
    _cnicController.text = "12345-6789012-3";
    _licenseController.text = "LIC123456789";
    _vehicleModelController.text = "Toyota Corolla 2020";
    _vehicleNumberController.text = "KHI-2020";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryWhite,
      appBar: AppBar(
        backgroundColor: kPrimaryGreen,
        title: Text(
          'Driver Profile',
          style: TextStyle(color: kPrimaryWhite),
        ),
        leading: PrimaryBackButton(),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.close : Icons.edit,
              color: kPrimaryWhite,
            ),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture Section
            _buildProfilePictureSection(),
            SizedBox(height: 20),
            
            // Personal Information
            PrimaryHeading(
              heading: "Personal Information",
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 10),
            _buildPersonalInfoSection(),
            SizedBox(height: 20),
            
            // Vehicle Information
            PrimaryHeading(
              heading: "Vehicle Information",
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 10),
            _buildVehicleInfoSection(),
            SizedBox(height: 20),
            
            // Documents Section
            PrimaryHeading(
              heading: "Documents",
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 10),
            _buildDocumentsSection(),
            SizedBox(height: 20),
            
            // Action Buttons
            if (_isEditing) _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: kPrimaryGreen.withOpacity(0.1),
            child: Icon(
              Icons.person,
              size: 60,
              color: kPrimaryGreen,
            ),
          ),
          SizedBox(height: 10),
          if (_isEditing)
            TextButton.icon(
              onPressed: _changeProfilePicture,
              icon: Icon(Icons.camera_alt, color: kPrimaryGreen),
              label: Text(
                'Change Photo',
                style: TextStyle(color: kPrimaryGreen),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
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
          PrimaryTextField(
            controller: _nameController,
            hintText: "Full Name",
            enabled: _isEditing,
            prefixIcon: Icon(Icons.person),
          ),
          SizedBox(height: 15),
          PrimaryTextField(
            controller: _emailController,
            hintText: "Email Address",
            enabled: _isEditing,
            prefixIcon: Icon(Icons.email),
          ),
          SizedBox(height: 15),
          PrimaryTextField(
            controller: _phoneController,
            hintText: "Phone Number",
            enabled: _isEditing,
            prefixIcon: Icon(Icons.phone),
          ),
          SizedBox(height: 15),
          PrimaryTextField(
            controller: _cnicController,
            hintText: "CNIC Number",
            enabled: _isEditing,
            prefixIcon: Icon(Icons.credit_card),
          ),
          SizedBox(height: 15),
          PrimaryTextField(
            controller: _licenseController,
            hintText: "Driving License",
            enabled: _isEditing,
            prefixIcon: Icon(Icons.drive_eta),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoSection() {
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
          PrimaryTextField(
            controller: _vehicleModelController,
            hintText: "Vehicle Model",
            enabled: _isEditing,
            prefixIcon: Icon(Icons.directions_car),
          ),
          SizedBox(height: 15),
          PrimaryTextField(
            controller: _vehicleNumberController,
            hintText: "Vehicle Number",
            enabled: _isEditing,
            prefixIcon: Icon(Icons.confirmation_number),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection() {
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
          _buildDocumentItem('CNIC Front', 'Verified', Icons.credit_card),
          Divider(),
          _buildDocumentItem('CNIC Back', 'Verified', Icons.credit_card),
          Divider(),
          _buildDocumentItem('Driving License', 'Verified', Icons.drive_eta),
          Divider(),
          _buildDocumentItem('Vehicle Registration', 'Pending', Icons.description),
          Divider(),
          _buildDocumentItem('Insurance Certificate', 'Pending', Icons.security),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(String title, String status, IconData icon) {
    Color statusColor = status == 'Verified' ? Colors.green : Colors.orange;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: kPrimaryGreen),
          SizedBox(width: 15),
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
                SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 14,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (status != 'Verified')
            TextButton(
              onPressed: () => _uploadDocument(title),
              child: Text('Upload'),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            text: "Cancel",
            onPressed: _cancelEdit,
            color: Colors.grey,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: PrimaryButton(
            text: _isLoading ? "Saving..." : "Save Changes",
            onPressed: _isLoading ? () {} : () => _saveChanges(),
          ),
        ),
      ],
    );
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
    });
    _loadDriverData(); // Reload original data
  }

  void _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Implement API call to save changes
    await Future.delayed(Duration(seconds: 2)); // Simulate API call

    setState(() {
      _isLoading = false;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile updated successfully')),
    );
  }

  void _changeProfilePicture() {
    // TODO: Implement image picker
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile picture change coming soon')),
    );
  }

  void _uploadDocument(String documentType) {
    // TODO: Implement document upload
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Document upload for $documentType coming soon')),
    );
  }
}
