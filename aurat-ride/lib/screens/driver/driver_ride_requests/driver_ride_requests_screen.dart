import 'dart:async';
import 'package:aurat_ride/services/api_service.dart';
import 'package:aurat_ride/services/user_service.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:aurat_ride/utlils/helper_functions/helper_function.dart';
import 'package:flutter/material.dart';

class DriverRideRequestsScreen extends StatefulWidget {
  const DriverRideRequestsScreen({super.key});

  @override
  State<DriverRideRequestsScreen> createState() => _DriverRideRequestsScreenState();
}

class _DriverRideRequestsScreenState extends State<DriverRideRequestsScreen> {
  String? _userToken;
  List<dynamic> _rideRequests = [];
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userData = await UserService.getUserData();
    setState(() {
      _userToken = userData['token'];
    });
    
    if (_userToken != null) {
      await _loadRideRequests();
      _startAutoRefresh();
    }
  }

  Future<void> _loadRideRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getRides(_userToken!);
      
      if (response['success']) {
        setState(() {
          _rideRequests = response['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['error'] ?? 'Failed to load ride requests';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      _loadRideRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryWhite,
      appBar: AppBar(
        backgroundColor: kPrimaryGreen,
        title: Text(
          'Ride Requests',
          style: TextStyle(color: kPrimaryWhite),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kPrimaryWhite),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: kPrimaryWhite),
            onPressed: _loadRideRequests,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(_errorMessage!),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadRideRequests,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _rideRequests.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions_car, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No ride requests available',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'New requests will appear here',
                            style: TextStyle(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadRideRequests,
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _rideRequests.length,
                        itemBuilder: (context, index) {
                          final ride = _rideRequests[index];
                          return _buildRideRequestCard(ride);
                        },
                      ),
                    ),
    );
  }

  Widget _buildRideRequestCard(Map<String, dynamic> ride) {
    final status = ride['status'];
    final rider = ride['rider'];
    final estimatedFare = ride['estimated_fare'];
    final distance = ride['distance_km'];
    final pickupAddress = ride['pickup_address'];
    final dropoffAddress = ride['dropoff_address'];

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status and fare
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getStatusColor(status)),
                ),
                child: Text(
                  _getStatusText(status),
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                'PKR ${estimatedFare?.toStringAsFixed(2) ?? '0.00'}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          
          // Rider info
          if (rider != null) _buildRiderInfo(rider),
          
          // Route info
          _buildRouteInfo(pickupAddress, dropoffAddress, distance),
          
          // Action buttons
          SizedBox(height: 16),
          _buildActionButtons(ride, status),
        ],
      ),
    );
  }

  Widget _buildRiderInfo(Map<String, dynamic> rider) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: kPrimaryGreen,
            child: Text(
              rider['name']?.substring(0, 1).toUpperCase() ?? 'R',
              style: TextStyle(
                color: kPrimaryWhite,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rider['name'] ?? 'Rider',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  rider['phone'] ?? '',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 16),
              SizedBox(width: 4),
              Text(
                rider['rating']?.toString() ?? '4.5',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteInfo(String? pickupAddress, String? dropoffAddress, double? distance) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.my_location, color: Colors.green, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  pickupAddress ?? 'Pickup location',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.red, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  dropoffAddress ?? 'Dropoff location',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          if (distance != null) ...[
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.straighten, color: Colors.blue, size: 16),
                SizedBox(width: 8),
                Text(
                  '${distance.toStringAsFixed(1)} km',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> ride, String status) {
    return Row(
      children: [
        if (status == 'requested')
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _acceptRide(ride),
              icon: Icon(Icons.check, size: 18),
              label: Text('Accept'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: kPrimaryWhite,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        if (status == 'requested') ...[
          SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _rejectRide(ride),
              icon: Icon(Icons.close, size: 18),
              label: Text('Reject'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: kPrimaryWhite,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
        if (status == 'assigned')
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _startRide(ride),
              icon: Icon(Icons.play_arrow, size: 18),
              label: Text('Start Ride'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryGreen,
                foregroundColor: kPrimaryWhite,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        if (status == 'started')
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _completeRide(ride),
              icon: Icon(Icons.check_circle, size: 18),
              label: Text('Complete Ride'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: kPrimaryWhite,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'requested':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'driver_arriving':
        return Colors.purple;
      case 'started':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'requested':
        return 'NEW REQUEST';
      case 'assigned':
        return 'ASSIGNED';
      case 'driver_arriving':
        return 'ARRIVING';
      case 'started':
        return 'IN PROGRESS';
      case 'completed':
        return 'COMPLETED';
      case 'canceled':
        return 'CANCELED';
      default:
        return status.toUpperCase();
    }
  }

  Future<void> _acceptRide(Map<String, dynamic> ride) async {
    try {
      final response = await ApiService.acceptRide(
        token: _userToken!,
        rideId: ride['id'].toString(),
      );

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ride accepted successfully')),
        );
        _loadRideRequests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to accept ride: ${response['error']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _rejectRide(Map<String, dynamic> ride) async {
    try {
      final response = await ApiService.cancelRide(
        token: _userToken!,
        rideId: ride['id'].toString(),
      );

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ride rejected')),
        );
        _loadRideRequests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reject ride: ${response['error']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _startRide(Map<String, dynamic> ride) async {
    try {
      final response = await ApiService.startRide(
        token: _userToken!,
        rideId: ride['id'].toString(),
      );

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ride started')),
        );
        _loadRideRequests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start ride: ${response['error']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _completeRide(Map<String, dynamic> ride) async {
    try {
      final response = await ApiService.completeRide(
        token: _userToken!,
        rideId: ride['id'].toString(),
      );

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ride completed successfully')),
        );
        _loadRideRequests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to complete ride: ${response['error']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}
