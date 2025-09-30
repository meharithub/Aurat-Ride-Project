import 'dart:ui' as ui;
import 'dart:ui';
import 'package:aurat_ride/utlils/path/asset_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapFunctions {
  static final Map<String, BitmapDescriptor> _cache = {};

  /// Convert SVG asset to BitmapDescriptor with caching
  /// Convert an SVG asset into a BitmapDescriptor for Google Maps marker
  static Future<BitmapDescriptor> svgAssetToBitmapDescriptor(
    String assetPath, {
    int width = 64,
    int height = 64,
  }) async {
    // Load SVG as a widget
    final svgWidget = SvgPicture.asset(
      assetPath,
      width: width.toDouble(),
      height: height.toDouble(),
    );

    print("marker path : $kLocalImageBaseUrl/map-marker.png");
    // Render the widget into an image
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    // Define a fixed size to draw
    final Size size = Size(width.toDouble(), height.toDouble());

    // Render the widget
    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();
    final renderView = RenderView(
      view:
          PlatformDispatcher.instance.implicitView!, // ✅ replaces window/views
      child: RenderPositionedBox(
        alignment: Alignment.center,
        // child: renderRepaintBoundary,
      ),
      configuration: ViewConfiguration(
        // size: size,
        devicePixelRatio:
            ui.PlatformDispatcher.instance.views.first.devicePixelRatio,
      ),
    );

    final PipelineOwner pipelineOwner = PipelineOwner();
    renderView.prepareInitialFrame();
    final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());
    final RenderObjectToWidgetElement<RenderBox> rootElement =
        RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
            width: width.toDouble(),
            height: height.toDouble(),
            child: svgWidget),
      ),
    ).attachToRenderTree(buildOwner);
    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();
    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final ui.Image image = await recorder.endRecording().toImage(width, height);

    final ByteData? bytes =
        await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  /// Request precise location permission and get current position
  static Future<Position?> getCurrentPositionWithPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  static getAddressFromLatLng(LatLng currentPos) async {
    List<Placemark> placeMarks = await placemarkFromCoordinates(
        currentPos.latitude, currentPos.longitude);

    try {
      if (placeMarks.isNotEmpty) {
        final place = placeMarks.first;
        print("place markes: $placeMarks");
        print("place markes: $place");
        return "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      }
    } catch (e) {
      print("could not fetch address from coordinates: $e");
    }
  }
}
