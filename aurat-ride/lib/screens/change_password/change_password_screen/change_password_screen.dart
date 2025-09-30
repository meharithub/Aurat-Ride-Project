import 'package:aurat_ride/global_widgets/primary_button.dart';
import 'package:aurat_ride/global_widgets/primary_textfield.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:flutter/material.dart';

import '../../../global_widgets/primary_back_button.dart';
import '../../../global_widgets/primary_description_text.dart';

class ChangePasswordScreen extends StatelessWidget {
  ChangePasswordScreen({super.key});

  final TextEditingController _old = TextEditingController();
  final TextEditingController _new = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPrimaryWhite,
      child: SafeArea(
          child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: Column(
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
                            "Settings",
                            style: TextStyle(
                              fontSize: 20,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    PrimaryTextField(
                      controller: _old,
                      hintText: "Old Password",
                      suffixIcon: Icon(Icons.remove_red_eye),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    PrimaryTextField(
                      controller: _new,
                      hintText: "New Password",
                      suffixIcon: Icon(Icons.remove_red_eye),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    PrimaryTextField(
                      controller: _confirm,
                      hintText: "Confirm Password",
                      suffixIcon: Icon(Icons.remove_red_eye),
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    PrimaryButton(text: "Save", onPressed: () {}),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      )),
    );
  }
}
