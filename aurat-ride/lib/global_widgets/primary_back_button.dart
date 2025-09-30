import 'package:aurat_ride/utlils/helper_functions/helper_function.dart';
import 'package:flutter/material.dart';

class PrimaryBackButton extends StatelessWidget {
  const PrimaryBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        HelperFunctions.navigateBack(context);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.arrow_back_ios,
            size: 14,
          ),
          Text(
            "Back",
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
