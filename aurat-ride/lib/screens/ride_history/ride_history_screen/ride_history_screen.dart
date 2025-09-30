import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:flutter/material.dart';

import '../../../global_widgets/primary_back_button.dart';

class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(color: kPrimaryWhite,
        child: SafeArea(child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: PrimaryBackButton(),
                          ),
                          Center(
                            child: Text(
                              "Ride History",
                              style: TextStyle(
                                fontSize: 20,
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20,),
              ],
            ),
          ),
        )),);
  }
}
