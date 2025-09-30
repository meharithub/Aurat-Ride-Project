import 'package:aurat_ride/global_widgets/primary_description_text.dart';
import 'package:aurat_ride/global_widgets/primary_heading.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:flutter/material.dart';

class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Ride History"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Upcoming"),
              Tab(text: "Completed"),
              Tab(text: "Cancelled"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            HistoryList(type: "upcoming"),
            HistoryList(type: "completed"),
            HistoryList(type: "cancelled"),
          ],
        ),
      ),
    );
  }
}

class HistoryList extends StatelessWidget {
  final String type;
  const HistoryList({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final rides = List.generate(
      6,
      (i) => {
        "title": "Ride #$i",
        "date": "12 Sept 2025",
        "status": type,
        "from": "Pickup Location $i",
        "to": "Dropoff Location $i",
      },
    );

    if (rides.isEmpty) {
      return Center(
        child: Text("No $type rides"),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: rides.length,
      itemBuilder: (context, index) {
        final ride = rides[index];
        return Card(
          color: kPrimaryWhite,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nate",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Mustang Shelby GT",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                PrimaryDescriptionText(text: "Today at 9:20 am"),
              ],
            ),
          ),
        );
      },
    );
  }
}
