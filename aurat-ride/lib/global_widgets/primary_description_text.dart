import 'package:flutter/material.dart';

class PrimaryDescriptionText extends StatelessWidget {
  final String text;
  const PrimaryDescriptionText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 14),
    );
  }
}
