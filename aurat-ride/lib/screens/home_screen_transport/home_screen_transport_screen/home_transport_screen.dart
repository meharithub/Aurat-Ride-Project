import 'dart:async';
import 'dart:convert';
import 'package:aurat_ride/global_widgets/primary_ink_well.dart';
import 'package:aurat_ride/global_widgets/primary_textfield.dart';
import 'package:aurat_ride/screens/home_screen_transport/home_screen_transport_screen/components/fare_bottom_sheet.dart';
import 'package:aurat_ride/utlils/helper_functions/helper_function.dart';
import 'package:aurat_ride/utlils/map_functions/google_places_functions/google_places_functions.dart';
import 'package:aurat_ride/services/api_service.dart';
import 'package:aurat_ride/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import '../../../utlils/theme/colors.dart';
import 'dart:math' show asin, cos, pi, sin, sqrt;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideBookingScreen extends StatefulWidget {
  const RideBookingScreen({super.key});

  @override
  State<RideBookingScreen> createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends State<RideBookingScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Location _location = Location();
  List<dynamic> predictions = [];
  bool _rideStarted = false;

  Timer? _timer;

  LatLng? _pickup;
  LatLng? _dropoff;
  List<LatLng>? cords;

  final FocusNode _pickupFocusNode = FocusNode();
  final FocusNode _dropOffFocusNode = FocusNode();

  LatLng? defaultPickupLocation;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();

  // StreamSubscription<LocationData>? _locationSubscription;
  StreamSubscription<LatLng>? _driverSub;

  // API Integration Variables
  String? _userToken;
  Map<String, dynamic>? _rideQuote;
  Map<String, dynamic>? _currentRide;
  bool _isLoading = false;
  String? _errorMessage;

  /// Simulates live tracking along the drawn polyline
  Stream<LatLng> liveTrackingStream(List<LatLng> routeCoords) async* {
    for (LatLng point in routeCoords) {
      await Future.delayed(const Duration(seconds: 1)); // update every 1 sec
      yield point; // emit current location along polyline
    }
  }

  // void _startLiveTracking(List<LatLng> routeCoords) {
  //   _driverSub?.cancel(); // cancel previous subscription if running
  //   _driverSub = liveTrackingStream(routeCoords).listen((LatLng position) {
  //     setState(() {
  //       _markers.removeWhere((m) => m.markerId.value == "driver");
  //       _markers.add(Marker(
  //         markerId: const MarkerId("driver"),
  //         position: position,
  //         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
  //       ));
  //     });
  //
  //     // Optional: keep camera following driver
  //     _controller.future.then((mapCtrl) {
  //       mapCtrl.animateCamera(CameraUpdate.newLatLng(position));
  //     });
  //   });
  //
  //   // Distance check to stop when reaching destination
  //   final distanceToDestination = Geolocator.distanceBetween(
  //     positon!.latitude,
  //     position.longitude,
  //     destination.latitude,
  //     destination.longitude,
  //   );
  //
  //
  // }

  /// Start tracking driver
  void _startLiveTracking(List<LatLng> routeCords) {
    _driverSub?.cancel(); // cancel any existing tracking

    _driverSub = liveTrackingStream(routeCords).listen((LatLng position) async {
      setState(() {
        _markers.removeWhere((m) => m.markerId.value == "driver");
        _markers.add(Marker(
          markerId: const MarkerId("driver"),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ));
      });

      // Keep camera following driver
      final mapCtrl = await _controller.future;

      if (mounted) {
        mapCtrl.animateCamera(CameraUpdate.newLatLng(position));
      }

      print("in the live tracking");
      // Distance check to stop when reaching destination
      final distanceToDestination =
          calculateDistanceInKm(position, _dropoff!); // in KM
      print("in the live tracking after $defaultPickupLocation");

      if (distanceToDestination <= 0.01) {
        print("✅ Driver reached destination!");
        _stopLiveTracking();

        if (mounted) {
          _driverArrivedAndStartingRide();
        }
      }
    });
  }

  /// Stop tracking driver
  void _stopLiveTracking() {
    _driverSub?.cancel();
    _driverSub = null;
    print("⛔ Live tracking stopped.");
  }

  // void _updateDriverMarker(LatLng driverLocation) {
  //   setState(() {
  //     _markers.removeWhere((m) => m.markerId.value == "driver");
  //     _markers.add(Marker(
  //       markerId: const MarkerId("driver"),
  //       position: driverLocation,
  //       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
  //     ));
  //   });
  //
  //   // Optional: animate camera to driver location
  //   _controller.future.then((mapCtrl) {
  //     mapCtrl.animateCamera(CameraUpdate.newLatLng(driverLocation));
  //   });
  // }

  trackFocusChanges() {
    print("track changes");
    _pickupFocusNode.addListener(() {
      if (_pickupFocusNode.hasFocus) {
        isPickField = true;
        print("this is picked $isPickField");
      }
    });
    _dropOffFocusNode.addListener(() {
      if (_dropOffFocusNode.hasFocus) {
        isPickField = false;
        print("this is drop off $isPickField");
      }
    });
  }

  setSuggestionVisibilityStatus() {
    if (_pickupController.text.isNotEmpty &&
        _dropoffController.text.isNotEmpty) {
      isSuggestionVisible = true;
    }
    setState(() {});
  }

  /// --- Fetch route and draw polyline ---
  Future<void> _drawRoute(LatLng pickup, LatLng dropoff) async {
    final url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${pickup.latitude},${pickup.longitude}&destination=${dropoff.latitude},${dropoff.longitude}&mode=driving&key=$apiKey";

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    if (data["status"] == "OK") {
      final points = data["routes"][0]["overview_polyline"]["points"];
      final List<LatLng> routeCoords = _decodePolyline(points);
      cords = routeCoords;

      setState(() {
        _polylines.clear();
        _polylines.add(Polyline(
          polylineId: const PolylineId("route"),
          color: Colors.blue,
          width: 5,
          points: routeCoords,
        ));
      });

      final controller = await _controller.future;
      final bounds = _boundsFromLatLngList(routeCoords);
      if (!mounted) return;
      if (controller == null) {
        print("MapController not ready yet!");
        return;
      }
      print("bound: ${bounds.toJson()}");
      await controller.animateCamera(CameraUpdate.newLatLngBounds(
        bounds,
        30,
      ));
    }
  }

  setPickupAddressInField(LatLng currentPos) async {
    List<Placemark> placeMarks = await placemarkFromCoordinates(
        currentPos.latitude, currentPos.longitude);
    String address = "";

    try {
      if (placeMarks.isNotEmpty) {
        final place = placeMarks.first;
        address =
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      }
    } catch (e) {
      print("could not fetch address from coordinates: $e");
    }
    _pickupController.text = address;
  }

  setDropOffAddressInField(LatLng currentPos) async {
    List<Placemark> placeMarks = await placemarkFromCoordinates(
        currentPos.latitude, currentPos.longitude);
    String address = "";

    try {
      if (placeMarks.isNotEmpty) {
        final place = placeMarks.first;
        print("place markes: $placeMarks");
        print("place markes: $place");
        address =
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      }
    } catch (e) {
      print("could not fetch address from coordinates: $e");
    }
    setDropOffAddress(address);
  }

  setDropOffAddress(String address) {
    _dropoffController.text = address;
  }

  /// --- Polyline decoding helper ---
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }

  /// --- Bounds helper ---
  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double x0 = list.first.latitude, x1 = list.first.latitude;
    double y0 = list.first.longitude, y1 = list.first.longitude;

    for (LatLng latLng in list) {
      if (latLng.latitude > x1) x1 = latLng.latitude;
      if (latLng.latitude < x0) x0 = latLng.latitude;
      if (latLng.longitude > y1) y1 = latLng.longitude;
      if (latLng.longitude < y0) y0 = latLng.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(x0, y0),
      northeast: LatLng(x1, y1),
    );
  }

  /// --- Set Pickup Marker ---
  void _setPickup(LatLng pos) {
    print("in setup pickup function starting");
    setState(() {
      print("in set state");
      _pickup = pos;
      print("updated pick up post $_pickup");
      _markers.removeWhere((m) => m.markerId.value == "pickup");
      _markers.add(Marker(
        markerId: const MarkerId("pickup"),
        position: pos,
        infoWindow: InfoWindow(title: "Your Pickup Location"),
        draggable: true,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        onDragEnd: (newPos) {
          print("in drag end function $newPos");
          _pickup = newPos;
          if (_dropoff != null) {
            _drawRoute(_pickup!, _dropoff!);
            setPickupAddressInField(_pickup!);
            FareBottomSheet.showFareSheet(context, _pickup!, _dropoff!,
                _pickupController.text, _dropoffController.text, () {
              _startLiveTracking(cords!);
            });
          }

          print("in draw route function executed");
        },
      ));
      print("in pick marker added");
      if (_pickup != null && _dropoff != null) {
        print("in other marker added");
        _drawRoute(_pickup!, _dropoff!);
        setPickupAddressInField(_pickup!);
        _getRideQuote(); // Get real quote from API
        FareBottomSheet.showFareSheet(context, _pickup!, _dropoff!,
            _pickupController.text, _dropoffController.text, () {
          _requestRide(); // Request real ride
        }, rideQuote: _rideQuote);
      }
    });
  }

  /// Add marker at user's current location on init
  Future<void> _addCurrentLocationMarker() async {
    try {
      final loc = await _location.getLocation();

      if (loc.latitude == null || loc.longitude == null) {
        print("Location not available yet.");
        return;
      }

      final currentPos = LatLng(loc.latitude!, loc.longitude!);
      print("Current location: ${currentPos.toJson()}");

      _pickup = currentPos;
      defaultPickupLocation = currentPos;

      // 🔹 Get human readable address using geocoding
      List<Placemark> placemarks = await placemarkFromCoordinates(
          currentPos.latitude, currentPos.longitude);

      String address = "";

      try {
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          address =
              "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        }
      } catch (e) {
        print("could not fetch address from coordinates: $e");
      }

      print("Pickup Address: $address");

      // update pickup text field with address
      _pickupController.text = address;

      if (mounted) {
        setState(() {
          _markers.removeWhere((m) => m.markerId.value == "current");
          _markers.add(Marker(
            markerId: const MarkerId("current"),
            position: currentPos,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure),
            infoWindow: InfoWindow(
                title: address.isNotEmpty ? address : "You are here"),
          ));
          animateCamera(currentPos);
        });
      }
    } catch (e) {
      print("Error in _addCurrentLocationMarker: $e");
    }
  }

  void animateCamera(LatLng target, {double zoom = 15}) async {
    print("in funtion: ${LatLng(target.latitude, target.longitude)}");
    final GoogleMapController controller = await _controller.future;
    if (mounted && controller != null) {
      print("in condition: ${LatLng(target.latitude, target.longitude)}");
      await controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: zoom, tilt: 10)));
    }
  }

  bool isSuggestionVisible = false;

  @override
  void initState() {
    _addCurrentLocationMarker();
    trackFocusChanges();
    _loadUserToken();
    super.initState();
  }

  /// Load user token for API calls
  Future<void> _loadUserToken() async {
    final userData = await UserService.getUserData();
    setState(() {
      _userToken = userData['token'];
    });
  }

  /// Get ride quote from API
  Future<void> _getRideQuote() async {
    if (_pickup == null || _dropoff == null || _userToken == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getRideQuote(
        pickupLat: _pickup!.latitude,
        pickupLng: _pickup!.longitude,
        dropoffLat: _dropoff!.latitude,
        dropoffLng: _dropoff!.longitude,
      );

      if (response['success']) {
        setState(() {
          _rideQuote = response['data'];
        });
      } else {
        setState(() {
          _errorMessage = response['error'] ?? 'Failed to get ride quote';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Request a ride
  Future<void> _requestRide() async {
    if (_pickup == null || _dropoff == null || _userToken == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.requestRide(
        token: _userToken!,
        pickupLat: _pickup!.latitude,
        pickupLng: _pickup!.longitude,
        pickupAddress: _pickupController.text,
        dropoffLat: _dropoff!.latitude,
        dropoffLng: _dropoff!.longitude,
        dropoffAddress: _dropoffController.text,
        polyline: _encodePolyline(cords ?? []),
      );

      if (response['success']) {
        setState(() {
          _currentRide = response['data']['ride'];
        });
        _showRideRequestedDialog();
      } else {
        setState(() {
          _errorMessage = response['error'] ?? 'Failed to request ride';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Encode polyline for API
  String _encodePolyline(List<LatLng> points) {
    // Simple polyline encoding - in production, use proper polyline encoding
    return points.map((p) => '${p.latitude},${p.longitude}').join('|');
  }

  /// Show ride requested dialog
  void _showRideRequestedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Ride Requested'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Looking for nearby drivers...'),
            if (_currentRide != null) ...[
              SizedBox(height: 8),
              Text('Ride ID: ${_currentRide!['id']}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelRide();
            },
            child: Text('Cancel Ride'),
          ),
        ],
      ),
    );
  }

  /// Cancel current ride
  Future<void> _cancelRide() async {
    if (_currentRide == null || _userToken == null) return;

    try {
      final response = await ApiService.cancelRide(
        token: _userToken!,
        rideId: _currentRide!['id'].toString(),
      );

      if (response['success']) {
        setState(() {
          _currentRide = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ride cancelled successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel ride: ${e.toString()}')),
      );
    }
  }

  /// --- Set Dropoff Marker ---
  void _setDropOff(LatLng pos) {
    setState(() {
      print("this is drop");
      _dropoff = pos;
      _markers.removeWhere((m) => m.markerId.value == "dropoff");
      _markers.add(Marker(
        markerId: const MarkerId("dropoff"),
        position: pos,
        draggable: true,
        infoWindow: InfoWindow(title: "Your Drop Off Location"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        onDragEnd: (newPos) {
          print("this is drag end");
          _dropoff = newPos;
          if (_pickup != null) {
            print("this is drag end in the success condition");
            _drawRoute(_pickup!, _dropoff!);
            setDropOffAddressInField(_dropoff!);
            FareBottomSheet.showFareSheet(context, _pickup!, _dropoff!,
                _pickupController.text, _dropoffController.text, () {
              _startLiveTracking(cords!);
            });
          }
        },
      ));
      if (_pickup != null) {
        print("this is drag end in the success condition");
        _drawRoute(_pickup!, _dropoff!);
        setDropOffAddressInField(_dropoff!);
        _getRideQuote(); // Get real quote from API
        FareBottomSheet.showFareSheet(context, _pickup!, _dropoff!,
            _pickupController.text, _dropoffController.text, () {
          _requestRide(); // Request real ride
        }, rideQuote: _rideQuote);
      }
    });
  }

  /// Haversine formula to calculate distance between two LatLng points
  double calculateDistanceInKm(LatLng start, LatLng end) {
    const double earthRadius = 6371; // in km
    final double dLat = _deg2rad(end.latitude - start.latitude);
    final double dLon = _deg2rad(end.longitude - start.longitude);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(start.latitude)) *
            cos(_deg2rad(end.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  /// Function to calculate fare
  Map<String, String> calculateFare(LatLng pickup, LatLng dropOff) {
    const double pricePerKm = 20.0;

    double distance = calculateDistanceInKm(pickup, dropOff);
    double fare = distance * pricePerKm;

    return {
      "distance": "${distance.toStringAsFixed(1)} km",
      "fare": "Rs ${fare.toStringAsFixed(0)}"
    };
  }

  bool isPickField = false;

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    // _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPrimaryGreen,
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          // appBar: AppBar(
          //   backgroundColor: kPrimaryGreen,
          //   leading: Container(),
          //   title: Text(
          //     "Aurat Ride",
          //     style: TextStyle(color: kPrimaryWhite),
          //   ),
          // ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: kPrimaryGreen,
            onPressed: () {},
            child: const Icon(
              Icons.navigation,
              color: kPrimaryWhite,
            ),
          ),
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(24.8607, 67.0011), // Karachi default
                  zoom: 12,
                ),
                onMapCreated: (c) {
                  if (!_controller.isCompleted) {
                    _controller.complete(c);
                  }
                },
                markers: _markers,
                polylines: _polylines,
                myLocationEnabled: false,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
              ),

              // Search fields
              Positioned(
                top: 20,
                left: 10,
                right: 10,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildSearchField(
                              controller: _pickupController,
                              hint: "Pickup Location",
                              onChanged: (val) {
                                setSuggestionVisibilityStatus();
                                isPickField = true;
                                final PlacesService placesServices =
                                    PlacesService(apiKey);
                                if (val.toString().isNotEmpty) {
                                  placesServices
                                      .getPredictions(val.toString())
                                      .then((res) {
                                    predictions = res;
                                  });
                                }
                                print("predictions: ${predictions.toList()}");
                                setState(() {});
                              }),
                        ),
                        IconButton(
                            onPressed: () {
                              print("pickup location: ${_pickup?.toJson()}");
                              _setPickup(LatLng(defaultPickupLocation!.latitude,
                                  defaultPickupLocation!.longitude));
                            },
                            icon: Icon(
                              Icons.my_location,
                              color: kPrimaryGreen,
                              size: 32,
                            )),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildSearchField(
                      controller: _dropoffController,
                      hint: "Dropoff Location",
                      onChanged: (val) {
                        isPickField = false;
                        setSuggestionVisibilityStatus();
                        print("on changed drop off");
                        final PlacesService placesServices =
                            PlacesService(apiKey);
                        print("on changed drop off");
                        if (val.toString().isNotEmpty) {
                          print("on changed not empty");
                          placesServices
                              .getPredictions(val.toString())
                              .then((res) {
                            predictions = res;
                          });
                        }
                        print("predictions: ${predictions.toList()}");
                        setState(() {});
                      },
                    ),
                    Visibility(
                      visible: isSuggestionVisible,
                      child: Container(
                        color: kPrimaryWhite,
                        child: ListView.builder(
                            itemCount: predictions.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return PrimaryInkWell(
                                onTap: () async {
                                  print("is pick up field $isPickField");
                                  isSuggestionVisible = false;
                                  HelperFunctions.hideKeyBoard();

                                  final PlacesService placesServices =
                                      PlacesService(apiKey);
                                  final placeId =
                                      predictions[index]["place_id"];
                                  final latLng = await placesServices
                                      .getPlaceLatLng(placeId);

                                  print("latlng: ${latLng!.values.first}");

                                  final lat = latLng.values.first;
                                  final lng = latLng.values.last;
                                  print("lat: $lat");
                                  print("long: $lng");

                                  final address =
                                      predictions[index]["description"];

                                  if (isPickField) {
                                    // 👈 Update pickup field
                                    _pickupController.text = address;
                                    _setPickup(LatLng(lat, lng));
                                  } else {
                                    // 👈 Update dropoff field
                                    _dropoffController.text = address;
                                    _setDropOff(LatLng(lat, lng));
                                  }

                                  setState(() {});
                                },
                                child: ListTile(
                                  title:
                                      Text(predictions[index]['description']),
                                ),
                              );
                            }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// --- Search Field Widget ---
  Widget _buildSearchField({
    required TextEditingController controller,
    required String hint,
    required onChanged,
  }) {
    return PrimaryTextField(
        controller: controller,
        onChanged: onChanged,
        suffixIcon: Visibility(
            visible: controller.text.isNotEmpty,
            child: IconButton(
                onPressed: () {
                  controller.text = "";
                  setState(() {});
                },
                icon: Icon(Icons.close))),
        prefixIcon: Icon(Icons.location_on_outlined),
        textInputAction: TextInputAction.done,
        hintText: hint);
  }

  void _driverArrivedAndStartingRide() async {
    // Step 1: Show "Driver Arrived" message
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Driver Arrived"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text("Driver is starting the ride..."),
            ],
          ),
        );
      },
    );

    // Simulate a delay for the driver starting the ride
    await Future.delayed(Duration(seconds: 3));
    Navigator.pop(context); // Close the "Driver Arrived" dialog

    // Step 2: Start tracking the driver location
    LatLng pickupLocation =
        LatLng(37.7749, -122.4194); // Static pickup location
    LatLng destinationLocation =
        LatLng(37.7849, -122.4094); // Static destination location

    // Step 3: Show "Ride Completed" popup with rating widget
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Ride Completed"),
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
                HelperFunctions.navigateBack(context);
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  // Rating widget
  Widget _buildRatingWidget() {
    double _rating = 0;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Expanded(
                  child: IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1.0;
                      });
                    },
                  ),
                );
              }),
            ),
            Text("Rating: $_rating"),
          ],
        );
      },
    );
  }

  void _checkArrival(LatLng driverLocation, LatLng destination) {
    const double arrivalThreshold = 50.0; // in meters
    double distance = Geolocator.distanceBetween(
      driverLocation.latitude,
      driverLocation.longitude,
      destination.latitude,
      destination.longitude,
    );

    if (distance <= arrivalThreshold) {
      // Trigger "driver has arrived" pop-up
      _driverArrivedAndStartingRide();
    }
  }

//   void _driverStartedRide(List<LatLng> routeCoords) {
//     // Simulate the driver arriving at the pickup location
//     Future.delayed(Duration(seconds: 3), () {
//       if (mounted) {
//         showModalBottomSheet(
//           context: context,
//           shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           builder: (_) => const Center(
//             child: Padding(
//               padding: EdgeInsets.all(16),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     "Driver has arrived 🚗",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 10),
//                   CircularProgressIndicator(),
//                   SizedBox(height: 10),
//                   Text("Waiting for driver to start the ride..."),
//                 ],
//               ),
//             ),
//           ),
//         );

//         // Simulate the ride starting after 3 seconds
//         Future.delayed(Duration(seconds: 3), () {
//           Navigator.pop(context); // Close the previous bottom sheet

//           // Simulate tracking from pickup to destination
//           Future.delayed(Duration(seconds: 5), () {
//             if (mounted) {
//               showModalBottomSheet(
//                 context: context,
//                 shape: const RoundedRectangleBorder(
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//                 ),
//                 builder: (_) => Center(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Text(
//                           "Arrived at Destination 🎉",
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         const Text("Ride Completed!"),
//                         const SizedBox(height: 20),
//                         ElevatedButton(
//                           onPressed: () {
//                             // Handle rating submission
//                           },
//                           child: const Text("Rate Your Driver"),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             }
//           });
//         });
//       }
//     });
//   }
}
