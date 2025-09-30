import 'package:aurat_ride/global_widgets/primary_back_button.dart';
import 'package:aurat_ride/global_widgets/primary_button.dart';
import 'package:aurat_ride/global_widgets/primary_heading.dart';
import 'package:aurat_ride/global_widgets/primary_light_black_subheading.dart';
import 'package:aurat_ride/global_widgets/primary_textfield.dart';
import 'package:aurat_ride/screens/email_number_verification/email_phone_verification_screen/email_phone_verification_screen.dart';
import 'package:aurat_ride/screens/login/login_screen/login_screen.dart';
import 'package:aurat_ride/utlils/helper_functions/helper_function.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:flutter/material.dart';

class SetNewPasswordScreen extends StatelessWidget {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  SetNewPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPrimaryWhite,
      child: SafeArea(
          child: Scaffold(
            resizeToAvoidBottomInset: true,
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: PrimaryBackButton(),
              ),
              const SizedBox(
                height: 20,
              ),
              PrimaryHeading(heading: "Set Password"),
              const SizedBox(
                height: 20,
              ),
              PrimaryLightBlackSubheading(text: "Set your password"),
              const SizedBox(
                height: 30,
              ),
              PrimaryTextField(
                controller: _passwordController,
                hintText: "Enter your password",
                suffixIcon: Icon(
                  Icons.remove_red_eye,
                  color: kBorderColor,
                ),
                keyboardType: TextInputType.visiblePassword,
              ),
              const SizedBox(
                height: 20,
              ),
              PrimaryTextField(
                controller: _confirmPasswordController,
                hintText: "Confirm your password",
                suffixIcon: Icon(
                  Icons.remove_red_eye,
                  color: kBorderColor,
                ),
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.visiblePassword,
              ),
              const SizedBox(
                height: 20,
              ),
              const Spacer(),
              PrimaryButton(
                  text: "Update Password",
                  onPressed: () {
                   HelperFunctions.navigateTo(context, LoginScreen());
                  }),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      )),
    );
  }
}
