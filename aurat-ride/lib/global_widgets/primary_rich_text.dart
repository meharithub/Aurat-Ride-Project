import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:flutter/material.dart';

class PrimaryRichText extends StatelessWidget {
  final String firstPart;
  final String greenPart1;
  final String middlePart;
  final String greenPart2;
  final String lastPart;

  const PrimaryRichText({
    super.key,
    required this.firstPart,
    required this.greenPart1,
    required this.middlePart,
    required this.greenPart2,
    required this.lastPart,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: 3,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black,
        ),
        children: [
          TextSpan(
              text: firstPart, style: TextStyle(fontFamily: 'Roboto Slab')),
          TextSpan(
            text: greenPart1,
            style: const TextStyle(
                color: kPrimaryGreen,
                fontWeight: FontWeight.w600,
                fontFamily: "Roboto Slab"),
          ),
          TextSpan(
              text: middlePart, style: TextStyle(fontFamily: 'Roboto Slab')),
          TextSpan(
            text: greenPart2,
            style: const TextStyle(
                color: kPrimaryGreen,
                fontFamily: "Roboto Slab",
                fontWeight: FontWeight.w600),
          ),
          TextSpan(text: lastPart, style: TextStyle(fontFamily: 'Roboto Slab')),
        ],
      ),
    );
  }
}
