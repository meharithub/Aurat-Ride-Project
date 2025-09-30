import 'package:aurat_ride/global_widgets/primary_textfield.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:flutter/material.dart';

class PrimaryPhoneField extends StatelessWidget {
  final List<String> countryCodes;
  final String selectedCode;
  final ValueChanged<String?> onCodeChanged;
  final TextEditingController controller;

  const PrimaryPhoneField({
    super.key,
    required this.countryCodes,
    required this.selectedCode,
    required this.onCodeChanged,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorderColor),
      ),
      child: Row(
        children: [
          // Country Dropdown
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCode,
              icon: Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  // size: 24,
                ),
              ),
              items: countryCodes.map((code) {
                return DropdownMenuItem(
                  value: code,
                  child: Text(
                    code,
                    style: TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: onCodeChanged,
            ),
          ),

          // Divider
          Container(
            height: 25,
            width: 1,
            color: kBorderColor,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),

          // Phone number field
          Expanded(
            child: PrimaryTextField(
              controller: controller,
              hintText: "Enter your number",
              borderColor: kPrimaryWhite,
              focusedBorderColor: kPrimaryWhite,
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    );
  }
}
