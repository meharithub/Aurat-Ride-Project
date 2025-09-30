import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:flutter/material.dart';

class PrimaryInkWell extends StatelessWidget {
  final Function()? onTap;
  final Widget child;
  final double radius;
  // please don't remove default values, it may effect some of designs!
  const PrimaryInkWell(
      {super.key, this.onTap, required this.child, this.radius = 8});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        splashColor: kPrimaryGreen.withOpacity(0.2),
        onTap: onTap,
        child: child,
      ),
    );
  }
}
