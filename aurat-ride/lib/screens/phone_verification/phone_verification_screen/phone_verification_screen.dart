import 'package:aurat_ride/global_widgets/prefix_action_text.dart';
import 'package:aurat_ride/global_widgets/primary_back_button.dart';
import 'package:aurat_ride/global_widgets/primary_button.dart';
import 'package:aurat_ride/global_widgets/primary_heading.dart';
import 'package:aurat_ride/global_widgets/primary_light_black_subheading.dart';
import 'package:aurat_ride/global_widgets/primary_otp.dart';
import 'package:aurat_ride/screens/email_number_verification/email_phone_verification_screen/email_phone_verification_screen.dart';
import 'package:aurat_ride/screens/set_new_password/set_new_password_screen/set_new_password_screen.dart';
import 'package:aurat_ride/utlils/helper_functions/helper_function.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:flutter/material.dart';

class PhoneVerificationScreen extends StatelessWidget {
  const PhoneVerificationScreen({super.key});

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
                  alignment: Alignment.centerLeft, child: PrimaryBackButton()),
              const SizedBox(
                height: 20,
              ),
              PrimaryHeading(heading: "Phone Verification"),
              const SizedBox(
                height: 20,
              ),
              PrimaryLightBlackSubheading(text: "Enter your OTP code"),
              const SizedBox(
                height: 30,
              ),
              PrimaryOTP(
                length: 6,
                onCompleted: (otp) {
                  print("Entered OTP: $otp");
                  // handle verification
                },
              ),
              const SizedBox(
                height: 20,
              ),
              PrefixActionText(
                  onTap: () {},
                  actionText: "Resend again",
                  prefixText: "Didn't receive code? "),
              const SizedBox(
                height: 30,
              ),
              Spacer(),
              PrimaryButton(
                  text: "Verify",
                  onPressed: () {
                   HelperFunctions.navigateTo(context, SetNewPasswordScreen());
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
