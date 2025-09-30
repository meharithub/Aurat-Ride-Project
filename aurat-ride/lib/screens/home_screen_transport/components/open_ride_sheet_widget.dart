import 'dart:ffi';

import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';

import '../../../global_widgets/primary_local_svg.dart';
import '../../../utlils/path/asset_paths.dart';

class OpenRideSheetWidget extends StatelessWidget {
  final TextEditingController pickUpController;
  final TextEditingController dropOffController;
  final Function(LatLng) onSetDropOffLocation, onSetPickUpLocation;
  final Function onOpenConfirmRideSheet;
  final Function(LatLng pickLatLng, LatLng dropLatLng) onDrawPolyLine;

  OpenRideSheetWidget(
      {super.key,
      required this.onSetDropOffLocation,
      required this.onSetPickUpLocation,
      required this.onDrawPolyLine,
      required this.onOpenConfirmRideSheet,
      required this.pickUpController,
      required this.dropOffController});

  LatLng? tempPickUpLatLng;
  LatLng? tempDropOffLatLng;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: StatefulBuilder(
        builder: (ctx, setModalState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Select your address',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              // Pickup

              GooglePlaceAutoCompleteTextField(
                  textEditingController: pickUpController,
                  inputDecoration: const InputDecoration(
                    hintText: "Pickup Location",
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  itemClick: (prediction) async {
                    pickUpController.text = prediction.description!;
                    final double lat = double.parse(prediction.lat.toString());
                    final double lng = double.parse(prediction.lng.toString());
                    tempPickUpLatLng = LatLng(lat, lng);
                    onSetPickUpLocation(LatLng(lat, lng));
                  },
                  googleAPIKey: apiKey),
              const SizedBox(
                height: 20,
              ),
              GooglePlaceAutoCompleteTextField(
                  textEditingController: dropOffController,
                  inputDecoration: const InputDecoration(
                    hintText: "Dropoff Location",
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  itemClick: (prediction) async {
                    dropOffController.text = prediction.description!;
                    final double lat = double.parse(prediction.lat.toString());
                    final double lng = double.parse(prediction.lng.toString());
                    tempDropOffLatLng = LatLng(lat, lng);
                    onSetDropOffLocation(LatLng(lat, lng));
                  },
                  googleAPIKey: apiKey),

              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Select Transport',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: kPrimaryGreen.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          // PrimaryLocalSvg(
                          //     svgPath: "$kLocalImageBaseUrl/car.svg"),
                          Image.asset(
                            "$kLocalImageBaseUrl/car.png",
                            height: 44,
                          ),
                          const Text(
                            'Car',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Column(
                    children: [
                      // PrimaryLocalSvg(
                      //     svgPath: "$kLocalImageBaseUrl/bike.svg"),
                      Image.asset(
                        "$kLocalImageBaseUrl/bike.png",
                        height: 44,
                      ),
                      const Text(
                        'Bike',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    if (pickUpController.text.isNotEmpty) {
                      onSetPickUpLocation(tempPickUpLatLng!);
                    }
                    if (dropOffController.text.isNotEmpty) {
                      onSetDropOffLocation(tempDropOffLatLng!);
                    }

                    // If both are set, draw route
                    if (dropOffController.text != null &&
                        pickUpController.text != null) {
                      onDrawPolyLine(tempPickUpLatLng!, tempDropOffLatLng!);
                    }

                    Navigator.of(ctx).pop();
                    onOpenConfirmRideSheet();
                  },
                  child: const Text('Search Ride'),
                ),
              ),
              const SizedBox(height: 12),
              const SizedBox(
                height: 20,
              ),
            ],
          );
        },
      ),
    );
  }
}
