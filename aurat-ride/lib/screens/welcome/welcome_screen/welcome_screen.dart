import 'package:aurat_ride/global_widgets/primary_button.dart';
import 'package:aurat_ride/screens/login/login_screen/login_screen.dart';
import 'package:aurat_ride/screens/on_boarding/on_boarding_screen/widgets/on_boarding_image_with_text.dart';
import 'package:aurat_ride/screens/signup/signup_screen/signup_screen.dart';
import 'package:aurat_ride/utlils/helper_functions/helper_function.dart';
import 'package:aurat_ride/utlils/path/asset_paths.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPrimaryWhite,
      child: SafeArea(
          child: Scaffold(
        backgroundColor: kPrimaryWhite,
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: OnBoardingImageWithText(
                    imagePath: "$kLocalImageBaseUrl/welcome.svg",
                    heading: "Welcome",
                    description: "Have a better sharing experience"),
              ),
              const SizedBox(
                height: 20,
              ),
              PrimaryButton(
                  text: "Create an account",
                  onPressed: () {
                    HelperFunctions.navigateTo(context, SignupScreen());
                  }),
              const SizedBox(
                height: 20,
              ),
              PrimaryButton(
                  text: "Login",
                  color: kPrimaryWhite,
                  textColor: kPrimaryGreen,
                  onPressed: () {
                    HelperFunctions.navigateTo(context, LoginScreen());
                  }),
              const SizedBox(
                height: 40,
              ),
            ],
          ),
        ),
      )),
    );
  }
}
