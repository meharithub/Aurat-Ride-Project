import 'package:aurat_ride/screens/primary_bottom_menu/primary_bottom_menu.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../global_widgets/primary_back_button.dart';

class NotificationsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> notifications = [
    {
      "title": "Order Confirmed",
      "message": "Your order #123 has been confirmed",
      "date": DateTime.now(),
    },
    {
      "title": "New Message",
      "message": "You received a message from John",
      "date": DateTime.now(),
    },
    {
      "title": "Workout Reminder",
      "message": "Don’t forget your gym session today",
      "date": DateTime.now().subtract(Duration(days: 1)),
    },
    {
      "title": "Payment Successful",
      "message": "Your subscription payment is complete",
      "date": DateTime.now().subtract(Duration(days: 2)),
    },
  ];

  NotificationsScreen({super.key});

  String _getGroupTitle(DateTime date) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    if (DateUtils.isSameDay(today, date)) {
      return "Today";
    } else if (DateUtils.isSameDay(yesterday, date)) {
      return "Yesterday";
    } else {
      return DateFormat("dd MMM yyyy").format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group notifications by date
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in notifications) {
      String group = _getGroupTitle(item['date']);
      grouped.putIfAbsent(group, () => []);
      grouped[group]!.add(item);
    }

    final groupKeys = grouped.keys.toList();

    return Container(
      color: kPrimaryWhite,
      child: SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
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
                                "Notification",
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
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: groupKeys.length,
                    itemBuilder: (context, index) {
                      String group = groupKeys[index];
                      List<Map<String, dynamic>> groupItems = grouped[group]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section Header (Today, Yesterday, etc.)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              group,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w700),
                            ),
                          ),
                          // Notifications inside this section
                          ...groupItems.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Container(
                                width: double.maxFinite,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Color(0xffe3f5ed),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item['title'],
                                          style: const TextStyle(fontWeight: FontWeight.w600)),
                                      Text(item['message']),
                                      Text(group.toString())
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
