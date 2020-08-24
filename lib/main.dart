import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_jitter/src/route.dart';
import 'package:google_maps_flutter_jitter/src/ticker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  Polyline _route;
  Polyline _steps;
  BitmapDescriptor circleIcon;
  BitmapDescriptor mapMarkerIcon;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    getBytesFromAsset('assets/images/circle-outline-16.png', 20)
        .then((onValue) {
      circleIcon = BitmapDescriptor.fromBytes(onValue);
    });
    getBytesFromAsset('assets/images/map-marker-2-16.png', 30).then((onValue) {
      mapMarkerIcon = BitmapDescriptor.fromBytes(onValue);
    });
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        polylines: _polylines,
        markers: _markers,
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: _showMarkers,
            child: Icon(Icons.location_on),
          ),
          FloatingActionButton(
            onPressed: _animateRoute,
            child: Icon(Icons.slow_motion_video),
          ),
          FloatingActionButton(
            onPressed: _showRoute,
            child: Icon(Icons.directions),
          ),
        ],
      ),
    );
  }

  Future<void> _showRoute() async {
    if (_route == null) {
      // load the route from google directions api
      final route = await loadRoute();
      _route = Polyline(
        polylineId: PolylineId('route'),
        points: route,
        width: 3,
        color: Colors.black,
      );
      _polylines = {_route};
    } else {
      _route = null;
      _polylines = {};
      _markers = {};
    }
    setState(() {});
  }

  // Should be able to observe jitter on the device screen
  // as the animation proceeds.
  Future<void> _animateRoute() async {
    // load the intperpolated steps previously generated for the route
    // usingn a ticker from a flutter animator
    final steps = await loadSteps();
    // approximate the ticker from the flutter animator that was used
    // to generate the steps
    final duration = 5000; // milliseconds
    final interval = (duration / steps.length).round();
    final numTicks = (duration / interval).round();
    await for (final tick in Ticker().tick(numTicks, interval)) {
      // print(tick);
      _steps = Polyline(
        polylineId: PolylineId('steps'),
        points: steps.sublist(0, tick),
        width: 3,
        color: Colors.grey,
      );
      if (_route != null)
        _polylines = {_route, _steps};
      else
        _polylines = {_steps};
      _markers = {};
      setState(() {});
    }
  }

  void _showMarkers() {
    // add markers
    final routeMarkers = _route.points
        .asMap()
        .map(
          (key, value) => MapEntry(
            key,
            Marker(
              markerId: MarkerId('route: $value'),
              position: value,
              icon: mapMarkerIcon,
              infoWindow: InfoWindow(title: 'route[$key]: $value'),
            ),
          ),
        )
        .values
        .toSet();

    final stepMarkers = _steps.points
        .asMap()
        .map(
          (key, value) => MapEntry(
            key,
            Marker(
              markerId: MarkerId('step: $value'),
              position: value,
              icon: circleIcon,
              infoWindow: InfoWindow(title: 'step[$key]: $value'),
            ),
          ),
        )
        .values
        .toSet();
    _markers = stepMarkers.union(routeMarkers);
    setState(() {});
  }
}
