import 'package:aurat_ride/global_widgets/prefix_action_text.dart';
import 'package:aurat_ride/global_widgets/primary_back_button.dart';
import 'package:aurat_ride/global_widgets/primary_description_text.dart';
import 'package:aurat_ride/screens/email_number_verification/email_phone_verification_screen/email_phone_verification_screen.dart';
import 'package:aurat_ride/screens/primary_bottom_menu/primary_bottom_menu.dart';
import 'package:aurat_ride/screens/signup/signup_screen/signup_screen.dart';
import 'package:aurat_ride/screens/driver/driver_dashboard/driver_dashboard_screen.dart';
import 'package:aurat_ride/screens/admin/admin_dashboard_screen.dart';
import 'package:aurat_ride/services/api_service.dart';
import 'package:aurat_ride/services/user_service.dart';
import 'package:aurat_ride/utlils/helper_functions/helper_function.dart';
import 'package:flutter/material.dart';

import '../../../global_widgets/primary_button.dart';
import '../../../global_widgets/primary_divider.dart';
import '../../../global_widgets/primary_heading.dart';
import '../../../global_widgets/primary_social_button.dart';
import '../../../global_widgets/primary_textfield.dart';
import '../../../utlils/path/asset_paths.dart';
import '../../../utlils/theme/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response['success']) {
        // Save user data using UserService
        await UserService.saveUserData(
          token: response['data']['token'],
          role: response['data']['user']['role'] ?? 'rider',
          userId: response['data']['user']['id'].toString(),
          name: response['data']['user']['name'] ?? '',
          email: response['data']['user']['email'] ?? '',
        );
        
        // Navigate based on role
        final userRole = response['data']['user']['role']?.toLowerCase();
        if (userRole == 'admin') {
          HelperFunctions.navigateReplace(context, const AdminDashboardScreen());
        } else if (userRole == 'driver') {
          HelperFunctions.navigateReplace(context, DriverDashboardScreen());
        } else {
          HelperFunctions.navigateReplace(context, PrimaryBottomSheet());
        }
      } else {
        _showSnackBar(response['error'] ?? 'Login failed');
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
                      heading: "Login with your email or phone number",
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    PrimaryTextField(
                      controller: _emailController,
                      hintText: "Enter your email or number",
                      keyboardType: TextInputType.emailAddress,
                      // prefixIcon: Icon(Icons.person),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    PrimaryTextField(
                      controller: _passwordController,
                      hintText: "Enter your password",
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                      obscureText: true,
                      // prefixIcon: Icon(Icons.person),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    PrimaryButton(
                      text: _isLoading ? "Logging in..." : "Login", 
                      onPressed: _isLoading ? () {} : () => _handleLogin()
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: (){
                            HelperFunctions.navigateTo(context, EmailPhoneVerificationScreen());
                          },
                            child: PrimaryDescriptionText(text: "Forgot Password? "))),
                    const SizedBox(
                      height: 8,
                    ),
                    PrimaryDivider(),
                    const SizedBox(
                      height: 20,
                    ),
                    PrimarySocialButton(
                        svgPath: "$kLocalImageBaseUrl/google-icon.svg",
                        text: "Login with Google",
                        onTap: () {
                          //todo
                        }),
                    const SizedBox(
                      height: 15,
                    ),
                    PrimarySocialButton(
                        svgPath: "$kLocalImageBaseUrl/fb-icon.svg",
                        text: "Login with Facebook",
                        onTap: () {
                          //todo
                        }),
                    const SizedBox(
                      height: 15,
                    ),
                    PrimarySocialButton(
                        svgPath: "$kLocalImageBaseUrl/apple-icon.svg",
                        text: "Login with Apple",
                        onTap: () {
                          //todo
                        }),
                    const SizedBox(
                      height: 20,
                    ),
                    PrefixActionText(
                        onTap: (){
                          HelperFunctions.navigateTo(context, SignupScreen());
                        },
                        actionText: "Register",
                        prefixText: "Don't have an account? "),
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
