import 'package:flutter/material.dart';

class PrimaryHeading extends StatelessWidget {
  final String heading;
  final TextAlign textAlign;
  const PrimaryHeading({super.key, required this.heading, this.textAlign = TextAlign.center});

  @override
  Widget build(BuildContext context) {
    return Text(
      heading,
      textAlign: textAlign,
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    );
  }
}
