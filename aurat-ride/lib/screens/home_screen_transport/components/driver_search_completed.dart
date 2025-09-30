import 'package:aurat_ride/global_widgets/primary_button.dart';
import 'package:aurat_ride/screens/chat/chat_screen/chat_screen.dart';
import 'package:aurat_ride/utlils/helper_functions/helper_function.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:flutter/material.dart';

class DriverSearchCompleted extends StatelessWidget {
  const DriverSearchCompleted({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: kPrimaryWhite,
      decoration: BoxDecoration(
        color: kPrimaryWhite,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Container(
            //   width: 50,
            //   height: 5,
            //   decoration: BoxDecoration(
            //     color: kPrimaryWhite,
            //     borderRadius: BorderRadius.circular(10),
            //   ),
            // ),
            const SizedBox(height: 12),
            const ListTile(
              leading: CircleAvatar(
                backgroundColor: kPrimaryGreen,
                child: Icon(Icons.social_distance, color: Colors.white),
              ),
              title: Text("Estimated Arrival Time"),
              subtitle: Text("Driver will arrive in approx. 2 minutes"),
            ),
            const ListTile(
              leading: CircleAvatar(
                backgroundColor: kPrimaryGreen,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text("Driver: Ahmed Khan"),
              subtitle: Text("Contact: +92 300 1234567"),
            ),
            const ListTile(
              leading: CircleAvatar(
                backgroundColor: kPrimaryGreen,
                child: Icon(Icons.directions_car_filled, color: kPrimaryWhite),
              ),
              title: Text("Car: Toyota Corolla"),
              subtitle: Text("Car No: ABC-123"),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                children: [
                  Expanded(
                      child: PrimaryButton(
                          borderColor: Colors.red,
                          textColor: Colors.red,
                          color: kPrimaryWhite,
                          text: "Cancel Ride",
                          onPressed: () {
                            HelperFunctions.navigateBack(context);
                          })),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                      child: PrimaryButton(
                          text: "Contact Driver",
                          onPressed: () {
                            HelperFunctions.navigateTo(context, ChatScreen());
                          })),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
