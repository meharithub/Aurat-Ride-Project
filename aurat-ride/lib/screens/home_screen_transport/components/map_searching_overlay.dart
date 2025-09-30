import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:flutter/material.dart';

import 'pulse_circle.dart';

class MapSearchingOverlay extends StatelessWidget {
  const MapSearchingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing marker
        const PulsingCircle(size: 120, color: kPrimaryGreen),

        // Info card
        Align(
          alignment: Alignment.center,
          child: Container(
            height: 200,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Center(child: CircularProgressIndicator(color: kPrimaryGreen)),
                // SizedBox(height: 16),
                // Text("Searching for nearby drivers...",
                //     style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
