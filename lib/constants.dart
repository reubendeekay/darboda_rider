import 'package:flutter/material.dart';

const kPrimaryColor = Colors.black;
const kSecondaryColor = Colors.purple;

final kBorder = const Color(0xFF1A1A1A).withOpacity(0.1);
const kDark = Color(0xff264653);

OutlineInputBorder outlineBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(10),
  borderSide: BorderSide(
    color: const Color(0xFF1A1A1A).withOpacity(0.1),
    width: 1,
  ),
);
UnderlineInputBorder inputBorder = const UnderlineInputBorder(
  borderSide: BorderSide(
    color: kDark,
    width: 1,
  ),
);

OutlineInputBorder focusedBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(10),
  borderSide: const BorderSide(
    color: kDark,
    width: 1,
  ),
);

OutlineInputBorder errorBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(10),
  borderSide: const BorderSide(
    color: Colors.red,
    width: 1,
  ),
);

List<Map> onboardingTitles = [
  {
    'title': 'Welcome to Darboda',
    'description':
        'Darboda is a platform that connects you to the best bodas in your area. Enjoy the convenience of the most popular, fastest and preferred method of transport at the click of a button',
    'image': 'assets/images/onboarding1.jpeg'
  },
  {
    'title': 'A Boda for yourself or parcels',
    'description':
        'Get a boda in a few clicks. Choose your preferred boda and get a ride to your destination. The best part you can transport your goods faster and securely with no paperwork',
    'image': 'assets/images/onboarding2.webp',
  },
  {
    'title': 'Thank you for choosing us',
    'description':
        'Choosing us is choosing reliability, accountability and exceptional service. We welcome you to a large community of riders waiting to serve you. Again Karibu Sana!',
    'image': 'assets/images/onboarding3.jpeg',
  }
];

const mapBoxClientKey =
    'sk.eyJ1IjoicmV1YmVuamVmd2EiLCJhIjoiY2w4dzV0c2t5MGh5ejNvbG1xNDg1ejBlbiJ9.kmVTLWyZ5X86wDMEXwfNsQ';




/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darboda_rider/constants.dart';
import 'package:darboda_rider/helpers/distance_helper.dart';
import 'package:darboda_rider/providers/auth_provider.dart';
import 'package:darboda_rider/providers/location_provider.dart';
import 'package:darboda_rider/providers/request_provider.dart';
import 'package:darboda_rider/screens/trail/widgets/customer_widget.dart';

import 'package:flutter/material.dart';
import 'package:google_map_polyline_new/google_map_polyline_new.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marker_icon/marker_icon.dart';
import 'package:provider/provider.dart';

class TrailScreen extends StatefulWidget {
  const TrailScreen({Key? key, required this.rideId}) : super(key: key);
  final String rideId;

  @override
  State<TrailScreen> createState() => _TrailScreenState();
}

class _TrailScreenState extends State<TrailScreen> {
  GoogleMapController? _controller;

  final Set<Marker> _markers = <Marker>{};
  final Map<PolylineId, Polyline> _polylines = <PolylineId, Polyline>{};
//Polyline patterns
  List<List<PatternItem>> patterns = <List<PatternItem>>[
    <PatternItem>[], //line
    <PatternItem>[PatternItem.dash(30.0), PatternItem.gap(20.0)], //dash
    <PatternItem>[PatternItem.dot, PatternItem.gap(10.0)], //dot
    <PatternItem>[
      //dash-dot
      PatternItem.dash(30.0),
      PatternItem.gap(20.0),
      PatternItem.dot,
      PatternItem.gap(20.0)
    ],
  ];

  _addPolyline(List<LatLng> _coordinates) {
    PolylineId id = const PolylineId("1");
    Polyline polyline = Polyline(
        polylineId: id,
        patterns: patterns[0],
        color: Colors.blueAccent,
        points: _coordinates,
        width: 10,
        onTap: () {});

    setState(() {
      _polylines[id] = polyline;
    });
  }

//google cloud api key
  GoogleMapPolyline googleMapPolyline =
      GoogleMapPolyline(apiKey: "AIzaSyDIL1xyrMndlk2dSSSSikdobR8qDjz0jjQ");

  void _onMapCreated(GoogleMapController controller) async {
    _controller = controller;
    // String value = await DefaultAssetBundle.of(context)
    //     .loadString('assets/map_style.json');
    // _controller!.setMapStyle(value);
    final loc =
        Provider.of<LocationProvider>(context, listen: false).locationData!;
    final user = Provider.of<AuthProvider>(context, listen: false).user!;
    final requestModel =
        await Provider.of<RequestProvider>(context, listen: false)
            .getRequestedRide(widget.rideId);

    _markers.addAll([
      if (requestModel.riderId != null)
        Marker(
          markerId: const MarkerId('driver'),
          onTap: () {},
          //circle to show the mechanic profile in map
          icon: await MarkerIcon.pictureAsset(
              assetPath: 'assets/images/bike.png', height: 110, width: 110),
          position: LatLng(requestModel.rider!.currentLocation!.latitude,
              requestModel.rider!.currentLocation!.longitude),
        ),
      Marker(
        markerId: const MarkerId('customer'),
        onTap: () {},
        icon: await MarkerIcon.downloadResizePictureCircle(user.profilePic!,
            size: 100, borderColor: kPrimaryColor),
        position: LatLng(loc.latitude!, loc.longitude!),
      ),
    ]);
    setState(() {});
    if (requestModel.riderId != null) {
      var coordinates = await googleMapPolyline.getCoordinatesWithLocation(
          origin: LatLng(loc.latitude!, loc.longitude!),
          destination: LatLng(requestModel.destinationLocation!.latitude,
              requestModel.destinationLocation!.longitude),
          mode: RouteMode.driving);
      _addPolyline(coordinates!);

      setState(() {});
//Get center of the route
      final bounds = await googleMapPolyline.getCoordinatesWithLocation(
          origin: LatLng(loc.latitude!, loc.longitude!),
          destination: LatLng(requestModel.destinationLocation!.latitude,
              requestModel.destinationLocation!.longitude),
          mode: RouteMode.driving);
      final center = LatLng((bounds!.first.latitude + bounds.last.latitude) / 2,
          (bounds.first.longitude + bounds.last.longitude) / 2);

//Get LatLngBounds

      //Calculate zoom level to make sure the route is visible

      final zoom = getMapBoundZoom(
          boundsFromLatLngList(bounds),
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height);

      setState(() {
        _controller!.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: center, tilt: 90, zoom: zoom)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false).locationData!;

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('rides')
              .doc(widget.rideId)
              .snapshots(),
          builder: (context, snapshot) {
            return Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  polylines: _polylines.values.toSet(),
                  initialCameraPosition: CameraPosition(
                    target: LatLng(locationProvider.latitude!,
                        locationProvider.longitude!),
                    zoom: 18,
                  ),
                ),
                AnimatedPositioned(
                  bottom: snapshot.hasData ? 0 : -400,
                  duration: const Duration(milliseconds: 600),
                  left: 0,
                  right: 0,
                  child: CustomerWidget(
                    data: snapshot.data,
                  ),
                ),
              ],
            );
          }),
    );
  }
}


*/