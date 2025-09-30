import 'package:aurat_ride/screens/primary_bottom_menu/primary_bottom_menu.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:flutter/material.dart';

class OfferScreen extends StatelessWidget {
  const OfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPrimaryWhite,
      child: SafeArea(
        child: Column(
            children: [
              Center(
                child: Text(
                  "Offers",
                  style: TextStyle(
                    fontSize: 20,
                    // fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
        ),
      ),
    );
  }
}
