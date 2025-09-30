import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PrimaryLocalSvg extends StatelessWidget {
  final String svgPath;
  final Color? color;
  const PrimaryLocalSvg({super.key, required this.svgPath, this.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      svgPath,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null, // only apply if color is provided,
      placeholderBuilder: (context) => const SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
