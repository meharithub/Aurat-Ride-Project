import 'package:aurat_ride/global_widgets/primary_button.dart';
import 'package:aurat_ride/global_widgets/primary_textfield.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:flutter/material.dart';

import '../../../global_widgets/primary_phone_field.dart';

class ContactUsScreen extends StatefulWidget {
  ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _number = TextEditingController();
  final TextEditingController _message = TextEditingController();
  String selectedCode = "+92";

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPrimaryWhite,
      child: SafeArea(
          child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                Text(
                  "Contact us for Ride Share",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Address",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "House# 72, Road# 21, Banani, Dhaka-1213 (near Banani Bidyaniketon School & College, beside University of South Asia)",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Call : 13301 (24/7)",
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(
                  height: 2,
                ),
                Text(
                  "Email : support@pathao.com",
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Enter your message",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(
                  height: 15,
                ),
                PrimaryTextField(
                  controller: _name,
                  hintText: "Name",
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(
                  height: 20,
                ),
                PrimaryTextField(
                  controller: _message,
                  hintText: "Email",
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(
                  height: 20,
                ),
                PrimaryPhoneField(
                    countryCodes: ["+92", "+91", "+971"],
                    selectedCode: selectedCode,
                    onCodeChanged: (value) {
                      setState(() {
                        selectedCode = value!;
                      });
                    },
                    controller: _number),
                SizedBox(
                  height: 20,
                ),
                PrimaryTextField(
                  controller: _message,
                  maxLines: 4,
                  hintText: "Enter you message",
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.send,
                ),
                SizedBox(
                  height: 30,
                ),
                PrimaryButton(text: "Send Message", onPressed: () {}),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
