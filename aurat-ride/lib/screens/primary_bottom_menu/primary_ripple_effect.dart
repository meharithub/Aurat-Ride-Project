import 'package:aurat_ride/global_widgets/primary_local_svg.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:flutter/material.dart';


class PrimaryImageWithRippleEffect extends StatelessWidget {
  final Function() onTap;
  final String imgPath;
  final double borderRadius;
  final double height, width;
  final Color? imageColor;
  final BoxFit fit;
  const PrimaryImageWithRippleEffect(
      {this.width = 65,
        this.height = 65,
        super.key,
        this.imageColor = kPrimaryGreen,
        this.fit = BoxFit.contain,
        required this.onTap,
        required this.imgPath,
        this.borderRadius = 15});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(borderRadius), // Ripple effect inside circle
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent, // Transparent to show ripple
        ),
        child: PrimaryLocalSvg(
          // imgPath,
          // width: width,
          // height: height,
          // color: imageColor,
          // fit: fit,
          svgPath: imgPath,
        ), // Load Image
      ),
    );
  }
}
