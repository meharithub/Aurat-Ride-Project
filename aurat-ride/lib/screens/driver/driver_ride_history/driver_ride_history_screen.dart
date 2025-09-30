import 'package:aurat_ride/global_widgets/primary_back_button.dart';
import 'package:aurat_ride/global_widgets/primary_heading.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:flutter/material.dart';

class DriverRideHistoryScreen extends StatefulWidget {
  const DriverRideHistoryScreen({super.key});

  @override
  State<DriverRideHistoryScreen> createState() => _DriverRideHistoryScreenState();
}

class _DriverRideHistoryScreenState extends State<DriverRideHistoryScreen> {
  String _selectedFilter = 'All';
  List<Map<String, dynamic>> _rides = [
    {
      'id': '12345',
      'customer': 'Sara Ahmed',
      'pickup': 'Clifton Block 2',
      'dropoff': 'DHA Phase 5',
      'fare': 250.0,
      'rating': 4.5,
      'status': 'Completed',
      'date': '2024-01-15',
      'time': '14:30',
      'duration': '25 mins',
      'distance': '8.5 km',
    },
    {
      'id': '12344',
      'customer': 'Ali Khan',
      'pickup': 'Gulshan Block 6',
      'dropoff': 'Saddar',
      'fare': 180.0,
      'rating': 5.0,
      'status': 'Completed',
      'date': '2024-01-15',
      'time': '12:15',
      'duration': '20 mins',
      'distance': '6.2 km',
    },
    {
      'id': '12343',
      'customer': 'Fatima Sheikh',
      'pickup': 'Korangi',
      'dropoff': 'North Nazimabad',
      'fare': 320.0,
      'rating': 4.0,
      'status': 'Completed',
      'date': '2024-01-14',
      'time': '16:45',
      'duration': '35 mins',
      'distance': '12.1 km',
    },
    {
      'id': '12342',
      'customer': 'Hassan Ali',
      'pickup': 'Defence Phase 2',
      'dropoff': 'Clifton Block 1',
      'fare': 150.0,
      'rating': 4.8,
      'status': 'Completed',
      'date': '2024-01-14',
      'time': '10:20',
      'duration': '18 mins',
      'distance': '5.8 km',
    },
    {
      'id': '12341',
      'customer': 'Ayesha Malik',
      'pickup': 'Jinnah International Airport',
      'dropoff': 'DHA Phase 8',
      'fare': 400.0,
      'rating': 4.2,
      'status': 'Completed',
      'date': '2024-01-13',
      'time': '09:30',
      'duration': '45 mins',
      'distance': '18.3 km',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryWhite,
      appBar: AppBar(
        backgroundColor: kPrimaryGreen,
        title: Text(
          'Ride History',
          style: TextStyle(color: kPrimaryWhite),
        ),
        leading: PrimaryBackButton(),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: kPrimaryWhite),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'All', child: Text('All Rides')),
              PopupMenuItem(value: 'Today', child: Text('Today')),
              PopupMenuItem(value: 'This Week', child: Text('This Week')),
              PopupMenuItem(value: 'This Month', child: Text('This Month')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          _buildFilterTabs(),
          
          // Rides List
          Expanded(
            child: _buildRidesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          _buildFilterChip('All', _selectedFilter == 'All'),
          SizedBox(width: 10),
          _buildFilterChip('Completed', _selectedFilter == 'Completed'),
          SizedBox(width: 10),
          _buildFilterChip('Cancelled', _selectedFilter == 'Cancelled'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryGreen : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? kPrimaryWhite : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildRidesList() {
    List<Map<String, dynamic>> filteredRides = _rides.where((ride) {
      if (_selectedFilter == 'All') return true;
      return ride['status'].toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();

    if (filteredRides.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 20),
            Text(
              'No rides found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Your ride history will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredRides.length,
      itemBuilder: (context, index) {
        final ride = filteredRides[index];
        return _buildRideCard(ride);
      },
    );
  }

  Widget _buildRideCard(Map<String, dynamic> ride) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kPrimaryWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Ride ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ride #${ride['id']}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryGreen,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(ride['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ride['status'],
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(ride['status']),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            
            // Customer Info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: kPrimaryGreen.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    color: kPrimaryGreen,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride['customer'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          SizedBox(width: 4),
                          Text(
                            '${ride['rating']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            
            // Route Info
            Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 20,
                      color: Colors.grey[300],
                    ),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride['pickup'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        ride['dropoff'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            
            // Ride Details
            Row(
              children: [
                _buildRideDetail(Icons.access_time, ride['duration']),
                SizedBox(width: 20),
                _buildRideDetail(Icons.straighten, ride['distance']),
                SizedBox(width: 20),
                _buildRideDetail(Icons.calendar_today, ride['date']),
              ],
            ),
            SizedBox(height: 12),
            
            // Fare and Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rs ${ride['fare'].toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryGreen,
                  ),
                ),
                Text(
                  ride['time'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideDetail(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'in_progress':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
