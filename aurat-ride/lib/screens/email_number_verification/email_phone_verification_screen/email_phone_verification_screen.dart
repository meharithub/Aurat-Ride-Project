import 'package:aurat_ride/global_widgets/primary_back_button.dart';
import 'package:aurat_ride/global_widgets/primary_button.dart';
import 'package:aurat_ride/global_widgets/primary_heading.dart';
import 'package:aurat_ride/global_widgets/primary_textfield.dart';
import 'package:aurat_ride/screens/complete_your_profile/complete_your_profile_screen/complete_your_profile_screen.dart';
import 'package:aurat_ride/screens/phone_verification/phone_verification_screen/phone_verification_screen.dart';
import 'package:aurat_ride/utlils/helper_functions/helper_function.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:flutter/material.dart';

class EmailPhoneVerificationScreen extends StatelessWidget {
  final TextEditingController _emailPhoneVerificationController =
      TextEditingController();
  EmailPhoneVerificationScreen({super.key});

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PrimaryBackButton(),
              const SizedBox(
                height: 20,
              ),
              PrimaryHeading(
                heading: "Verification email or phone number",
                textAlign: TextAlign.start,
              ),
              const SizedBox(
                height: 20,
              ),
              PrimaryTextField(
                  controller: _emailPhoneVerificationController,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.emailAddress,
                  hintText: "Enter your email or number"),
              const SizedBox(
                height: 20,
              ),
              const Spacer(),
              PrimaryButton(
                  text: "Send OTP",
                  onPressed: () {
                    HelperFunctions.navigateTo(
                        context, PhoneVerificationScreen());
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
