import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:flutter/material.dart';

class PrimaryDropdownPicker<T> extends StatelessWidget {
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final String hintText;
  final String? labelText;
  final void Function(T?) onChanged;
  final Widget? prefixIcon;
  final Color borderColor;
  final Color focusedBorderColor;
  final Color fillColor;
  final double borderRadius;

  const PrimaryDropdownPicker({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.borderRadius = 8,
    this.hintText = "Select an option",
    this.labelText,
    this.prefixIcon,
    this.borderColor = kBorderColor,
    this.focusedBorderColor = kBorderColor,
    this.fillColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      items: items,
      icon: Icon(Icons.keyboard_arrow_down_outlined),
      decoration: InputDecoration(
        filled: true,
        fillColor: fillColor,
        labelText: labelText,
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: focusedBorderColor, width: 1.5),
        ),
      ),
    );
  }
}
