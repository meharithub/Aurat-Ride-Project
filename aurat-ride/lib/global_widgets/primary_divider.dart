import 'package:flutter/material.dart';

class PrimaryDivider extends StatelessWidget {
  final String text;
  final Color lineColor;
  final Color textColor;
  final double thickness;
  final String fontFamily;

  const PrimaryDivider({
    super.key,
    this.text = "or",
    this.lineColor = Colors.black54,
    this.textColor = Colors.black54,
    this.thickness = 1.3,
    this.fontFamily = "Roboto Slab", // 👈 default font
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Divider(
            color: lineColor,
            thickness: thickness,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 2),
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontFamily: fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: lineColor,
            thickness: thickness,
          ),
        ),
      ],
    );
  }
}
