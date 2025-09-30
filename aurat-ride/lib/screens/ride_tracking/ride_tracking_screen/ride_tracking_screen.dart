import 'dart:async';
import 'package:aurat_ride/services/api_service.dart';
import 'package:aurat_ride/services/user_service.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:aurat_ride/utlils/helper_functions/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideTrackingScreen extends StatefulWidget {
  final Map<String, dynamic> ride;
  
  const RideTrackingScreen({
    super.key,
    required this.ride,
  });

  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen> {
  String? _userToken;
  Map<String, dynamic>? _rideDetails;
  Map<String, dynamic>? _driverLocation;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _locationTimer;

  final Completer<GoogleMapController> _mapController = Completer();
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userData = await UserService.getUserData();
    setState(() {
      _userToken = userData['token'];
    });
    
    if (_userToken != null) {
      await _loadRideDetails();
      _startLocationTracking();
    }
  }

  Future<void> _loadRideDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getRide(
        token: _userToken!,
        rideId: widget.ride['id'].toString(),
      );

      if (response['success']) {
        setState(() {
          _rideDetails = response['data'];
          _isLoading = false;
        });
        _updateMapMarkers();
      } else {
        setState(() {
          _errorMessage = response['error'] ?? 'Failed to load ride details';
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

  void _startLocationTracking() {
    _locationTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _updateDriverLocation();
    });
  }

  Future<void> _updateDriverLocation() async {
    if (_rideDetails == null || _rideDetails!['driver_id'] == null) return;

    try {
      final response = await ApiService.getLiveTracking(
        token: _userToken!,
        rideId: widget.ride['id'].toString(),
      );

      if (response['success'] && response['data'] != null) {
        setState(() {
          _driverLocation = response['data'];
        });
        _updateMapMarkers();
      }
    } catch (e) {
      print('Error updating driver location: $e');
    }
  }

  void _updateMapMarkers() {
    if (_rideDetails == null) return;

    _markers.clear();
    _polylines.clear();

    // Add pickup marker
    _markers.add(
      Marker(
        markerId: MarkerId('pickup'),
        position: LatLng(
          _rideDetails!['pickup_lat'],
          _rideDetails!['pickup_lng'],
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: 'Pickup Location'),
      ),
    );

    // Add dropoff marker
    _markers.add(
      Marker(
        markerId: MarkerId('dropoff'),
        position: LatLng(
          _rideDetails!['dropoff_lat'],
          _rideDetails!['dropoff_lng'],
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: 'Dropoff Location'),
      ),
    );

    // Add driver marker if location available
    if (_driverLocation != null) {
      _markers.add(
        Marker(
          markerId: MarkerId('driver'),
          position: LatLng(
            _driverLocation!['lat'],
            _driverLocation!['lng'],
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: 'Driver Location'),
        ),
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryWhite,
      appBar: AppBar(
        backgroundColor: kPrimaryGreen,
        title: Text(
          'Ride Tracking',
          style: TextStyle(color: kPrimaryWhite),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kPrimaryWhite),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: kPrimaryWhite),
            onPressed: _loadRideDetails,
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
                        onPressed: _loadRideDetails,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Map
                    Expanded(
                      flex: 2,
                      child: _buildMap(),
                    ),
                    
                    // Ride Details
                    Expanded(
                      flex: 1,
                      child: _buildRideDetails(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildMap() {
    if (_rideDetails == null) {
      return Center(child: Text('Loading map...'));
    }

    final center = LatLng(
      _rideDetails!['pickup_lat'],
      _rideDetails!['pickup_lng'],
    );

    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _mapController.complete(controller);
      },
      initialCameraPosition: CameraPosition(
        target: center,
        zoom: 15,
      ),
      markers: _markers,
      polylines: _polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }

  Widget _buildRideDetails() {
    if (_rideDetails == null) return Container();

    final status = _rideDetails!['status'];
    final driver = _rideDetails!['driver'];
    final estimatedFare = _rideDetails!['estimated_fare'];
    final finalFare = _rideDetails!['final_fare'];

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status
          _buildStatusCard(status),
          SizedBox(height: 16),
          
          // Driver Info
          if (driver != null) _buildDriverCard(driver),
          
          // Fare Info
          _buildFareCard(estimatedFare, finalFare),
          
          // Action Buttons
          SizedBox(height: 16),
          _buildActionButtons(status),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String status) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'requested':
        statusText = 'Looking for driver...';
        statusColor = Colors.orange;
        statusIcon = Icons.search;
        break;
      case 'assigned':
        statusText = 'Driver assigned';
        statusColor = Colors.blue;
        statusIcon = Icons.person;
        break;
      case 'driver_arriving':
        statusText = 'Driver arriving';
        statusColor = Colors.blue;
        statusIcon = Icons.directions_car;
        break;
      case 'started':
        statusText = 'Ride in progress';
        statusColor = Colors.green;
        statusIcon = Icons.play_arrow;
        break;
      case 'completed':
        statusText = 'Ride completed';
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'canceled':
        statusText = 'Ride canceled';
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusText = 'Unknown status';
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(Map<String, dynamic> driver) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: kPrimaryGreen,
            child: Text(
              driver['name']?.substring(0, 1).toUpperCase() ?? 'D',
              style: TextStyle(
                color: kPrimaryWhite,
                fontSize: 18,
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
                  driver['name'] ?? 'Driver',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  driver['phone'] ?? '',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    SizedBox(width: 4),
                    Text(
                      driver['rating']?.toString() ?? '4.5',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.phone, color: kPrimaryGreen),
            onPressed: () {
              // In production, implement phone call
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling driver...')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFareCard(double? estimatedFare, double? finalFare) {
    final fare = finalFare ?? estimatedFare ?? 0.0;
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Fare',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'PKR ${fare.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kPrimaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(String status) {
    return Row(
      children: [
        if (status == 'requested' || status == 'assigned')
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _cancelRide,
              icon: Icon(Icons.cancel),
              label: Text('Cancel Ride'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: kPrimaryWhite,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        if (status == 'completed')
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _rateRide,
              icon: Icon(Icons.star),
              label: Text('Rate Ride'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryGreen,
                foregroundColor: kPrimaryWhite,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _cancelRide() async {
    try {
      final response = await ApiService.cancelRide(
        token: _userToken!,
        rideId: widget.ride['id'].toString(),
      );

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ride cancelled successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel ride: ${response['error']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _rateRide() {
    // Navigate to rating screen
    // In production, implement rating screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rating feature coming soon!')),
    );
  }
}
