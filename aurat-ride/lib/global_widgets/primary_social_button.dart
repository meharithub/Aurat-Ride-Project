import 'package:aurat_ride/global_widgets/primary_ink_well.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PrimarySocialButton extends StatelessWidget {
  final String svgPath;
  final String text;
  final VoidCallback onTap;
  final double height;
  final double borderRadius;

  const PrimarySocialButton({
    super.key,
    required this.svgPath,
    required this.text,
    required this.onTap,
    this.height = 50,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryInkWell(
      onTap: onTap,
      radius: borderRadius,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              svgPath,
              height: 20,
              width: 20,
            ),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                // fontWeight: FontWeight.w500,
                fontFamily: "Roboto Slab", // customize font
              ),
            ),
          ],
        ),
      ),
    );
  }
}
