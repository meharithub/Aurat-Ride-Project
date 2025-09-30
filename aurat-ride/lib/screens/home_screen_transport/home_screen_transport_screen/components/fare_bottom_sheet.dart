import 'package:aurat_ride/screens/home_screen_transport/components/driver_search_completed.dart';
import 'package:aurat_ride/screens/home_screen_transport/components/map_searching_overlay.dart';
import 'package:aurat_ride/utlils/helper_functions/helper_function.dart';
import 'package:aurat_ride/utlils/map_functions.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';

class FareBottomSheet {
  static void showFareSheet(
      BuildContext context,
      LatLng pickup,
      LatLng dropoff,
      String pickUpAddress,
      String dropOffAddress,
      Function() startDriverTracking, {
      Map<String, dynamic>? rideQuote,
    }) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      elevation: 0,
      backgroundColor: kPrimaryWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String selectedVehicle = "Bike";

        double distance = _calculateDistanceInKm(pickup, dropoff);

        return StatefulBuilder(
          builder: (context, setState) {
            double pricePerKm;
            double minutesPerKm;

            if (selectedVehicle == "Bike") {
              pricePerKm = 15.0;
              minutesPerKm = 2.0;
            } else if (selectedVehicle == "Economical Car") {
              pricePerKm = 23.0;
              minutesPerKm = 3.0;
            } else if (selectedVehicle == "AC Car") {
              pricePerKm = 30.0;
              minutesPerKm = 3.0;
            } else {
              pricePerKm = 20.0; // fallback
              minutesPerKm = 3.0;
            }

            // String pickUpAddress = MapFunctions.getAddressFromLatLng(pickup).toString();
            // String dropOffAddress = MapFunctions.getAddressFromLatLng(dropoff).toString();

            // Use API data if available, otherwise calculate locally
            double fare = rideQuote?['estimated_fare']?.toDouble() ?? (distance * pricePerKm);
            double apiDistance = rideQuote?['distance_km']?.toDouble() ?? distance;
            int eta = (apiDistance * minutesPerKm).round();

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Row(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     Icon(
                  //       Icons.my_location,
                  //       color: kPrimaryGreen,
                  //     ),
                  //     Expanded(
                  //       child: Padding(
                  //         padding: const EdgeInsets.only(left: 8.0),
                  //         child: Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             const Text("Pickup Location", style: TextStyle(
                  //                 fontSize: 14, fontWeight: FontWeight.bold),),
                  //             Text(pickUpAddress, maxLines: 3,),
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Icon(
                          Icons.location_on_outlined,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Drop Off Location",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  dropOffAddress,
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ChoiceChip(
                        label: const Text("Bike"),
                        selected: selectedVehicle == "Bike",
                        onSelected: (_) =>
                            setState(() => selectedVehicle = "Bike"),
                        selectedColor: Colors.green.shade100,
                      ),
                      ChoiceChip(
                        label: const Text("Economical Car"),
                        selected: selectedVehicle == "Economical Car",
                        onSelected: (_) =>
                            setState(() => selectedVehicle = "Economical Car"),
                        selectedColor: Colors.green.shade100,
                      ),
                      ChoiceChip(
                        label: const Text("AC Car"),
                        selected: selectedVehicle == "AC Car",
                        onSelected: (_) =>
                            setState(() => selectedVehicle = "AC Car"),
                        selectedColor: Colors.green.shade100,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Estimated Distance",
                          style: TextStyle(fontSize: 14)),
                      Text("${apiDistance.toStringAsFixed(1)} km",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Estimated Fare",
                          style: TextStyle(fontSize: 14)),
                      Text("Rs ${fare.toStringAsFixed(0)}",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Estimated Arrival",
                          style: TextStyle(fontSize: 14)),
                      Text("$eta min",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      HelperFunctions.navigateBack(
                          context); // hide the model sheet

                      // Call the parent's ride request method
                      startDriverTracking();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryGreen,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("Confirm Ride",
                        style: TextStyle(fontSize: 16, color: kPrimaryWhite)),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static double _calculateDistanceInKm(LatLng start, LatLng end) {
    const double earthRadius = 6371; // km
    final dLat = _deg2rad(end.latitude - start.latitude);
    final dLon = _deg2rad(end.longitude - start.longitude);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(start.latitude)) *
            cos(_deg2rad(end.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  static double _deg2rad(double deg) => deg * (pi / 180);

  static void checkMarkerPosition(
      BuildContext context, LatLng markerPosition, LatLng destinationPosition) {
    if (markerPosition == destinationPosition) {
      // if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Ride Completed 123"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Please rate your driver:"),
                SizedBox(height: 10),
                _buildRatingWidget(),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text("Submit"),
              ),
            ],
          );
        },
      );
    }
    // }
  }

  static Widget _buildRatingWidget() {
    // Implement your rating widget here
    return Container();
  }
}
