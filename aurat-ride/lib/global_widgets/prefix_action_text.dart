import 'package:flutter/material.dart';

import '../utlils/theme/colors.dart';

class PrefixActionText extends StatelessWidget {
  final String prefixText, actionText;
  final Function() onTap;
  const PrefixActionText(
      {super.key,
      required this.onTap,
      required this.actionText,
      required this.prefixText});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          prefixText,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(
          width: 2,
        ),
        InkWell(
          onTap: onTap,
          child: Text(
            actionText,
            style: TextStyle(
                fontSize: 14,
                color: kPrimaryGreen,
                fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
