import 'package:aurat_ride/global_widgets/primary_description_text.dart';
import 'package:aurat_ride/global_widgets/primary_heading.dart';
import 'package:aurat_ride/global_widgets/primary_ink_well.dart';
import 'package:aurat_ride/screens/change_password/change_password_screen/change_password_screen.dart';
import 'package:aurat_ride/screens/complete_your_profile/complete_your_profile_screen/complete_your_profile_screen.dart';
import 'package:aurat_ride/screens/favourite/favourite_screen/favourite_screen.dart';
import 'package:aurat_ride/screens/home_screen_transport/ride_history/ride_history_screen/ride_history_screen.dart';
import 'package:aurat_ride/screens/login/login_screen/login_screen.dart';
import 'package:aurat_ride/utlils/helper_functions/helper_function.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../global_widgets/primary_back_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPrimaryWhite,
      child: SafeArea(
          child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(right: 20, left: 20, bottom: 20),
          child: Column(
            children: [
              // const SizedBox(height: 10,),
              Text(
                "Settings",
                style: TextStyle(
                  fontSize: 20,
                  // fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              PrimaryInkWell(
                onTap: () {
                  HelperFunctions.navigateTo(context, ChangePasswordScreen());
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: kPrimaryWhite,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kPrimaryGreen, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PrimaryDescriptionText(text: "Change Password"),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              PrimaryInkWell(
                onTap: () {
                  HelperFunctions.navigateTo(
                      context, CompleteYourProfileScreen());
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: kPrimaryWhite,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kPrimaryGreen, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PrimaryDescriptionText(text: "Profile Settings"),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              PrimaryInkWell(
                onTap: () {
                  HelperFunctions.navigateTo(context, RideHistoryScreen());
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: kPrimaryWhite,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kPrimaryGreen, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PrimaryDescriptionText(text: "Ride History"),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              PrimaryInkWell(
                onTap: () {
                  HelperFunctions.navigateTo(context, FavouriteScreen());
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: kPrimaryWhite,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kPrimaryGreen, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PrimaryDescriptionText(text: "Favourite Rides"),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              PrimaryInkWell(
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(
                    color: kPrimaryWhite,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kPrimaryGreen, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PrimaryDescriptionText(text: "Privacy Policy"),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              PrimaryInkWell(
                onTap: () {},
                child: Container(
                  decoration: BoxDecoration(
                    color: kPrimaryWhite,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kPrimaryGreen, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PrimaryDescriptionText(text: "Delete Account"),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              PrimaryInkWell(
                onTap: () {
                  HelperFunctions.navigateTo(context, LoginScreen());
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: kPrimaryWhite,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kPrimaryGreen, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PrimaryDescriptionText(text: "Logout"),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
