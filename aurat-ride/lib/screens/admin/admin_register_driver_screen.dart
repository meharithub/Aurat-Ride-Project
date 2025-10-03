import 'package:flutter/material.dart';
import 'package:aurat_ride/services/api_service.dart';
import 'package:aurat_ride/services/user_service.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:aurat_ride/utlils/helper_functions/helper_function.dart';
import 'package:aurat_ride/global_widgets/primary_button.dart';
import 'package:aurat_ride/global_widgets/primary_textfield.dart';
import 'package:aurat_ride/global_widgets/primary_heading.dart';

class AdminRegisterDriverScreen extends StatefulWidget {
  const AdminRegisterDriverScreen({super.key});

  @override
  State<AdminRegisterDriverScreen> createState() => _AdminRegisterDriverScreenState();
}

class _AdminRegisterDriverScreenState extends State<AdminRegisterDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _cnicController = TextEditingController();
  final _drivingLicenseController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _vehicleYearController = TextEditingController();
  final _vehicleColorController = TextEditingController();

  String? _selectedGender;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cnicController.dispose();
    _drivingLicenseController.dispose();
    _vehicleModelController.dispose();
    _vehicleNumberController.dispose();
    _vehicleYearController.dispose();
    _vehicleColorController.dispose();
    super.dispose();
  }

  Future<void> _registerDriver() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await UserService.getToken();
      if (token == null) {
        _showError('No authentication token found');
        return;
      }

      final response = await ApiService.registerDriver(
        token: token,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        gender: _selectedGender!,
        cnic: _cnicController.text.trim(),
        drivingLicense: _drivingLicenseController.text.trim(),
        vehicleModel: _vehicleModelController.text.trim(),
        vehicleNumber: _vehicleNumberController.text.trim(),
        vehicleYear: _vehicleYearController.text.isNotEmpty 
            ? int.tryParse(_vehicleYearController.text) 
            : null,
        vehicleColor: _vehicleColorController.text.trim().isNotEmpty 
            ? _vehicleColorController.text.trim() 
            : null,
      );

      if (response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Driver registered successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        _showError(response['message'] ?? 'Failed to register driver');
      }
    } catch (e) {
      _showError('Error registering driver: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryWhite,
      appBar: AppBar(
        title: const Text(
          'Register Driver',
          style: TextStyle(
            color: kPrimaryWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: kPrimaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personal Information Section
              PrimaryHeading(
                heading: "Personal Information",
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 16),
              
              PrimaryTextField(
                controller: _nameController,
                hintText: "Full Name",
                prefixIcon: const Icon(Icons.person),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              PrimaryTextField(
                controller: _emailController,
                hintText: "Email Address",
                prefixIcon: const Icon(Icons.email),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email address';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              PrimaryTextField(
                controller: _phoneController,
                hintText: "Phone Number",
                prefixIcon: const Icon(Icons.phone),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Gender Dropdown
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select gender';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              PrimaryTextField(
                controller: _cnicController,
                hintText: "CNIC Number",
                prefixIcon: const Icon(Icons.credit_card),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter CNIC number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Password Fields
              PrimaryTextField(
                controller: _passwordController,
                hintText: "Password",
                prefixIcon: const Icon(Icons.lock),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              PrimaryTextField(
                controller: _confirmPasswordController,
                hintText: "Confirm Password",
                prefixIcon: const Icon(Icons.lock_outline),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Driving Information Section
              PrimaryHeading(
                heading: "Driving Information",
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 16),
              
              PrimaryTextField(
                controller: _drivingLicenseController,
                hintText: "Driving License Number",
                prefixIcon: const Icon(Icons.drive_eta),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter driving license number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Vehicle Information Section
              PrimaryHeading(
                heading: "Vehicle Information",
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 16),
              
              PrimaryTextField(
                controller: _vehicleModelController,
                hintText: "Vehicle Model (e.g., Toyota Corolla 2020)",
                prefixIcon: const Icon(Icons.directions_car),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vehicle model';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              PrimaryTextField(
                controller: _vehicleNumberController,
                hintText: "Vehicle Number (e.g., KHI-2020)",
                prefixIcon: const Icon(Icons.confirmation_number),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vehicle number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              PrimaryTextField(
                controller: _vehicleYearController,
                hintText: "Vehicle Year (Optional)",
                prefixIcon: const Icon(Icons.calendar_today),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final year = int.tryParse(value);
                    if (year == null || year < 1990 || year > DateTime.now().year) {
                      return 'Please enter a valid year';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              PrimaryTextField(
                controller: _vehicleColorController,
                hintText: "Vehicle Color (Optional)",
                prefixIcon: const Icon(Icons.palette),
              ),
              const SizedBox(height: 32),
              
              // Register Button
              PrimaryButton(
                text: _isLoading ? "Registering..." : "Register Driver",
                onPressed: () => _registerDriver(),
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
