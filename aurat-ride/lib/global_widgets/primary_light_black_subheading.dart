import 'package:flutter/material.dart';

class PrimaryLightBlackSubheading extends StatelessWidget {
  final String text;
  const PrimaryLightBlackSubheading({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16, color: Colors.black54),
    );
  }
}
