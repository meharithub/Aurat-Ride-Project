import 'package:aurat_ride/global_widgets/primary_back_button.dart';
import 'package:aurat_ride/global_widgets/primary_button.dart';
import 'package:aurat_ride/global_widgets/primary_dropdown.dart';
import 'package:aurat_ride/global_widgets/primary_heading.dart';
import 'package:aurat_ride/global_widgets/primary_textfield.dart';
import 'package:aurat_ride/screens/home_screen_transport/home_screen_transport_screen/home_transport_screen.dart';
import 'package:aurat_ride/screens/primary_bottom_menu/primary_bottom_menu.dart';
import 'package:aurat_ride/utlils/helper_functions/helper_function.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:flutter/material.dart';

import '../../../global_widgets/primary_image_picker.dart';
import '../../../global_widgets/primary_phone_field.dart';

class CompleteYourProfileScreen extends StatefulWidget {

  const CompleteYourProfileScreen({super.key});

  @override
  State<CompleteYourProfileScreen> createState() => _CompleteYourProfileScreenState();
}

class _CompleteYourProfileScreenState extends State<CompleteYourProfileScreen> {
  final TextEditingController _fullNameController = TextEditingController();

  final TextEditingController _phoneNumberController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _streetController = TextEditingController();

  String? city;

  String? country;

  String selectedCode = "+880";

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPrimaryWhite,
      child: SafeArea(
          child: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: PrimaryBackButton(),
                              ),
                              Center(
                                child: Text(
                                  "Profile",
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),

                    PrimaryAvatar(
                      size: 96,
                      imageUrl: null, // or an existing avatar URL
                      onImagePicked: (file) {
                        // upload or save
                      },
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    PrimaryTextField(
                        controller: _fullNameController,
                        keyboardType: TextInputType.name,
                        hintText: "Enter your full name"),
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
                    PrimaryTextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        hintText: "Enter your email"),
                    const SizedBox(
                      height: 15,
                    ),
                    PrimaryTextField(
                        controller: _streetController,
                        keyboardType: TextInputType.text,
                        hintText: "Enter your email"),
                    const SizedBox(
                      height: 15,
                    ),
                    PrimaryDropdownPicker<String>(
                      value: city,
                      hintText: "Select City",
                      items: ["Lahore", "Karachi"]
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
                        city = val;
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    PrimaryDropdownPicker<String>(
                      value: country,
                      hintText: "Select City",
                      items: ["Pakistan", "America"]
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
                        country = val;
                      },
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                              text: "Cancel",
                              color: kPrimaryWhite,
                              textColor: kPrimaryGreen,
                              onPressed: () {}),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: PrimaryButton(text: "Save", onPressed: () {
                              // HelperFunctions.navigateTo(context, HomeTransportScreen());
                            })),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          )
      ),
    );
  }
}
