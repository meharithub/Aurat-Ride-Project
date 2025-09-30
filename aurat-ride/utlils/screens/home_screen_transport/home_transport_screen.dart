import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:your_project/utils/helper_functions/shortest_path.dart';

class HomeTransportScreen extends StatefulWidget {
  @override
  _HomeTransportScreenState createState() => _HomeTransportScreenState();
}

class _HomeTransportScreenState extends State<HomeTransportScreen> {
  GoogleMapController? mapController;
  List<LatLng> currentRoutes = []; // Your current polyline routes
  List<LatLng> optimizedRoute = [];

  @override
  void initState() {
    super.initState();
    optimizedRoute = findShortestPath(currentRoutes);
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _drawRoutes();
  }

  void _drawRoutes() {
    setState(() {
      // Clear existing polylines
      // Add optimized route polyline
      Polyline optimizedPolyline = Polyline(
        polylineId: PolylineId('optimized_route'),
        points: optimizedRoute,
        color: Colors.blue,
        width: 5,
      );
      // Add the polyline to the map
      mapController?.addPolyline(optimizedPolyline);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transport Routes')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(0, 0), // Set your initial position
          zoom: 10,
        ),
      ),
    );
  }
}