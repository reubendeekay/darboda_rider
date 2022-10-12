// ignore_for_file: unused_field

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darboda_rider/constants.dart';
import 'package:darboda_rider/providers/location_provider.dart';
import 'package:darboda_rider/providers/request_provider.dart';
import 'package:darboda_rider/screens/trail/widgets/cancelled_ride.dart';
import 'package:darboda_rider/screens/trail/widgets/customer_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_mapbox/flutter_mapbox.dart';
import 'package:iconsax/iconsax.dart';

import 'package:provider/provider.dart';

class TrailScreen extends StatefulWidget {
  const TrailScreen({Key? key, required this.rideId}) : super(key: key);
  final String rideId;

  @override
  State<TrailScreen> createState() => _TrailScreenState();
}

class _TrailScreenState extends State<TrailScreen> {
  String? _instruction = "";

  MapBoxNavigation? _directions;
  MapBoxOptions? _options;

  bool _isMultipleStop = true;
  double? _distanceRemaining, _durationRemaining;
  MapBoxNavigationViewController? _controller;
  bool _routeBuilt = false;
  bool _isNavigating = false;
  var _wayPoints = <WayPoint>[];

  @override
  void initState() {
    super.initState();
    Future((() => initialize()));
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initialize() async {
    try {
      final locationProvider =
          Provider.of<LocationProvider>(context, listen: false).locationData!;

      _directions = MapBoxNavigation(onRouteEvent: _onEmbeddedRouteEvent);
      var options = MapBoxOptions(
          initialLatitude: locationProvider.latitude,
          initialLongitude: locationProvider.longitude,
          zoom: 20.0,
          tilt: 30.0,
          bearing: 0.0,
          enableRefresh: true,
          alternatives: true,
          voiceInstructionsEnabled: false,
          bannerInstructionsEnabled: false,
          allowsUTurnAtWayPoints: true,
          animateBuildRoute: true,
          isOptimized: true,
          mode: MapBoxNavigationMode.drivingWithTraffic,
          units: VoiceUnits.imperial,
          simulateRoute: false,
          longPressDestinationEnabled: true,
          mapStyleUrlDay:
              "mapbox://styles/reubenjefwa/cl8w7hmsi000r14qsj5lhjhbu",
          mapStyleUrlNight:
              "mapbox://styles/reubenjefwa/cl8w7hmsi000r14qsj5lhjhbu",
          language: "en");

      setState(() {
        _options = options;
      });
      final requestModel =
          await Provider.of<RequestProvider>(context, listen: false)
              .getRequestedRide(widget.rideId);
      var wayPoints = <WayPoint>[];
      wayPoints.add(
        WayPoint(
            name: 'Your location',
            latitude: locationProvider.latitude,
            longitude: locationProvider.longitude),
      );
      wayPoints.add(
        WayPoint(
            name: 'Pickup',
            latitude: requestModel.pickupLocation!.latitude,
            longitude: requestModel.pickupLocation!.longitude),
      );
      wayPoints.add(
        WayPoint(
            name: 'Destination',
            latitude: requestModel.destinationLocation!.latitude,
            longitude: requestModel.destinationLocation!.longitude),
      );
      setState(() {
        _wayPoints = wayPoints;
      });
      await _controller!.buildRoute(wayPoints: wayPoints, options: options);
      _controller!.startNavigation(
        options: options,
      );

      // await _directions!
      //     .startNavigation(wayPoints: wayPoints, options: _options!);
    } catch (err) {}
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false).locationData!;

    var options = MapBoxOptions(
        initialLatitude: locationProvider.latitude,
        initialLongitude: locationProvider.longitude,
        zoom: 20.0,
        tilt: 30.0,
        bearing: 0.0,
        enableRefresh: true,
        alternatives: true,
        voiceInstructionsEnabled: true,
        bannerInstructionsEnabled: true,
        allowsUTurnAtWayPoints: true,
        animateBuildRoute: true,
        isOptimized: true,
        mode: MapBoxNavigationMode.drivingWithTraffic,
        units: VoiceUnits.imperial,
        simulateRoute: true,
        longPressDestinationEnabled: true,
        mapStyleUrlDay: "mapbox://styles/reubenjefwa/cl8w7hmsi000r14qsj5lhjhbu",
        mapStyleUrlNight:
            "mapbox://styles/reubenjefwa/cl8w7hmsi000r14qsj5lhjhbu",
        language: "en");

    return Scaffold(
        body: Stack(
      children: [
        MapBoxNavigationView(
            options: _options,
            onRouteEvent: _onEmbeddedRouteEvent,
            onCreated: (MapBoxNavigationViewController controller) async {
              _controller = controller;
              _controller!.initialize();
            }),
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('rides')
                .doc(widget.rideId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!['status'] == 'cancelled') {
                return const CancelledRide();
              }
              return AnimatedPositioned(
                bottom: snapshot.hasData ? 0 : -400,
                duration: const Duration(milliseconds: 600),
                left: 0,
                right: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 15),
                      height: 42,
                      width: 130,
                      child: ElevatedButton.icon(
                          onPressed: () {
                            _directions!.startNavigation(
                                wayPoints: _wayPoints, options: options);
                          },
                          style: ElevatedButton.styleFrom(
                              primary: kPrimaryColor,
                              onPrimary: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4))),
                          icon: const Icon(Icons.navigation_rounded),
                          label: const Text('Navigate')),
                    ),
                    CustomerWidget(
                      data: snapshot.data,
                    ),
                  ],
                ),
              );
            })
      ],
    ));
  }

  Future<void> _onEmbeddedRouteEvent(e) async {
    // _distanceRemaining = await _controller!.distanceRemaining;
    // _durationRemaining = await _controller!.durationRemaining;

    switch (e.eventType) {
      case MapBoxEvent.annotation_tapped:
        var annotation = _controller!.selectedAnnotation;
        print(annotation);
        break;
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        if (progressEvent.currentStepInstruction != null)
          _instruction = progressEvent.currentStepInstruction;
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        setState(() {
          _routeBuilt = true;
        });
        break;
      case MapBoxEvent.route_build_failed:
        setState(() {
          _routeBuilt = false;
        });
        break;
      case MapBoxEvent.navigation_running:
        setState(() {
          _isNavigating = true;
        });
        break;
      case MapBoxEvent.on_arrival:
        if (!_isMultipleStop) {
          await Future.delayed(const Duration(seconds: 3));
          await _controller!.finishNavigation();
        } else {}
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        setState(() {
          _routeBuilt = false;
          _isNavigating = false;
        });
        break;
      default:
        break;
    }
    setState(() {});
  }
}
