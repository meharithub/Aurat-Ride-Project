import 'package:aurat_ride/global_widgets/primary_heading.dart';
import 'package:aurat_ride/global_widgets/primary_light_black_subheading.dart';
import 'package:flutter/material.dart';

import '../../../../global_widgets/primary_local_svg.dart';

class OnBoardingImageWithText extends StatelessWidget {
  final String imagePath, heading, description;
  const OnBoardingImageWithText(
      {super.key,
      required this.description,
      required this.heading,
      required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        PrimaryLocalSvg(svgPath: imagePath),
        const SizedBox(
          height: 40,
        ),
        PrimaryHeading(heading: heading),
        const SizedBox(
          height: 20,
        ),
        PrimaryLightBlackSubheading(text: description),
      ],
    );
  }
}
