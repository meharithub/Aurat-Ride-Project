import 'package:aurat_ride/global_widgets/prefix_action_text.dart';
import 'package:aurat_ride/global_widgets/primary_back_button.dart';
import 'package:aurat_ride/global_widgets/primary_button.dart';
import 'package:aurat_ride/global_widgets/primary_divider.dart';
import 'package:aurat_ride/global_widgets/primary_dropdown.dart';
import 'package:aurat_ride/global_widgets/primary_heading.dart';
import 'package:aurat_ride/global_widgets/primary_local_svg.dart';
import 'package:aurat_ride/global_widgets/primary_phone_field.dart';
import 'package:aurat_ride/global_widgets/primary_rich_text.dart';
import 'package:aurat_ride/global_widgets/primary_social_button.dart';
import 'package:aurat_ride/global_widgets/primary_textfield.dart';
import 'package:aurat_ride/screens/home_screen_transport/home_screen_transport_screen/home_transport_screen.dart';
import 'package:aurat_ride/screens/login/login_screen/login_screen.dart';
import 'package:aurat_ride/screens/primary_bottom_menu/primary_bottom_menu.dart';
import 'package:aurat_ride/services/api_service.dart';
import 'package:aurat_ride/utlils/helper_functions/helper_function.dart';
import 'package:aurat_ride/utlils/path/asset_paths.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  String? selectedGender;
  String selectedCode = "+880";
  bool _isLoading = false;

  Future<void> _handleSignup() async {
    if (_nameController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _phoneNumberController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _cnicController.text.isEmpty ||
        selectedGender == null) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: selectedCode + _phoneNumberController.text.trim(),
        password: _passwordController.text,
        role: 'Rider', // Capital R as per API requirements
        cnic: _cnicController.text.trim(),
        gender: selectedGender ?? 'Male', // Pass selected gender
      );

      if (response['success']) {
        _showSnackBar('Registration successful! Please login.');
        HelperFunctions.navigateTo(context, LoginScreen());
      } else {
        _showSnackBar(response['error'] ?? 'Registration failed');
      }
    } catch (e) {
      _showSnackBar('Network error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPrimaryWhite,
      child: SafeArea(
          child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PrimaryBackButton(),
                const SizedBox(
                  height: 20,
                ),
                PrimaryHeading(
                  heading: "Sign up with your email or phone number",
                  textAlign: TextAlign.start,
                ),
                const SizedBox(
                  height: 20,
                ),
                PrimaryTextField(
                  controller: _nameController,
                  hintText: "Enter your name",
                  keyboardType: TextInputType.name,
                  // prefixIcon: Icon(Icons.person),
                ),
                const SizedBox(
                  height: 15,
                ),
                PrimaryTextField(
                  controller: _emailController,
                  hintText: "Enter your email",
                  keyboardType: TextInputType.emailAddress,
                  // prefixIcon: Icon(Icons.person),
                ),
                const SizedBox(
                  height: 15,
                ),
                PrimaryPhoneField(
                    countryCodes: ["+880", "+92", "+91", "+971"],
                    selectedCode: selectedCode,
                    onCodeChanged: (value) {
                      setState(() {
                        selectedCode = value!;
                      });
                    },
                    controller: _phoneNumberController),
                const SizedBox(
                  height: 15,
                ),
                PrimaryDropdownPicker<String>(
                  value: selectedGender,
                  hintText: "Select Gender",
                  items: ["Male", "Female"]
                      .map((country) => DropdownMenuItem(
                            value: country,
                            child: Text(
                              country,
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.normal),
                            ),
                          ))
                      .toList(),
                  onChanged: (val) {
                    selectedGender = val;
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                PrimaryTextField(
                  controller: _passwordController,
                  hintText: "Enter your password",
                  keyboardType: TextInputType.visiblePassword,
                  // prefixIcon: Icon(Icons.person),
                ),
                const SizedBox(
                  height: 15,
                ),
                PrimaryTextField(
                  controller: _confirmPasswordController,
                  hintText: "Confirm your password",
                  keyboardType: TextInputType.visiblePassword,
                  // prefixIcon: Icon(Icons.person),
                ),
                const SizedBox(
                  height: 15,
                ),
                PrimaryTextField(
                  controller: _cnicController,
                  hintText: "Enter your CNIC",
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  // prefixIcon: Icon(Icons.person),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PrimaryLocalSvg(
                        svgPath:
                            "$kLocalImageBaseUrl/agree-terms-check-icon.svg"),
                    const SizedBox(
                      width: 6,
                    ),
                    Expanded(
                      child: PrimaryRichText(
                          firstPart: "By signing up, you agree to the ",
                          greenPart1: "Terms and Conditions ",
                          middlePart: "and ",
                          greenPart2: "Privacy Policy",
                          lastPart: ""),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                PrimaryButton(
                  text: _isLoading ? "Signing up..." : "Signup", 
                  onPressed: _isLoading ? () {} : () => _handleSignup()
                ),
                const SizedBox(
                  height: 20,
                ),
                PrimaryDivider(),
                const SizedBox(
                  height: 20,
                ),
                PrimarySocialButton(
                    svgPath: "$kLocalImageBaseUrl/google-icon.svg",
                    text: "Signup with Google",
                    onTap: () {
                      //todo
                    }),
                const SizedBox(
                  height: 15,
                ),
                PrimarySocialButton(
                    svgPath: "$kLocalImageBaseUrl/fb-icon.svg",
                    text: "Signup with Facebook",
                    onTap: () {
                      //todo
                    }),
                const SizedBox(
                  height: 15,
                ),
                PrimarySocialButton(
                    svgPath: "$kLocalImageBaseUrl/apple-icon.svg",
                    text: "Signup with Apple",
                    onTap: () {
                      //todo
                    }),
                const SizedBox(
                  height: 20,
                ),
                PrefixActionText(
                    onTap: () {
                      HelperFunctions.navigateTo(context, LoginScreen());
                    },
                    actionText: "Sign in",
                    prefixText: "Already have an account? "),
                const SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
