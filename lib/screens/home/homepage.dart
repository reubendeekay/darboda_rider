import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darboda_rider/models/driver_model.dart';
import 'package:darboda_rider/providers/auth_provider.dart';
import 'package:darboda_rider/providers/location_provider.dart';
import 'package:darboda_rider/screens/home/widgets/home_appbar.dart';
import 'package:darboda_rider/screens/home/widgets/rider_request_card.dart';
import 'package:darboda_rider/widgets/online_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marker_icon/marker_icon.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  GoogleMapController? _controller;
  Set<Marker> _markers = <Marker>{};

  void _onMapCreated(GoogleMapController controller) async {
    _controller = controller;

    final drivers =
        Provider.of<LocationProvider>(context, listen: false).locationData;

    _markers.add(Marker(
      markerId: const MarkerId('You'),
      position: LatLng(drivers!.latitude!, drivers.longitude!),
      infoWindow: const InfoWindow(
        title: 'You',
      ),
      icon: await MarkerIcon.pictureAsset(
          assetPath: 'assets/images/rider.png', height: 130.h, width: 130.w),
    ));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false).locationData!;
    final rider = Provider.of<AuthProvider>(context, listen: false).rider!;
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('riders')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            return Stack(
              children: [
                GoogleMap(
                  zoomControlsEnabled: false,
                  markers: _markers,
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                      target: LatLng(locationProvider.latitude!,
                          locationProvider.longitude!),
                      zoom: 20,
                      tilt: 30),
                ),
                const Positioned(
                    top: 5, left: 15, right: 15, child: HomeAppBar()),
                if (!rider.isOnline)
                  const Positioned(
                    bottom: 15,
                    left: 15,
                    right: 15,
                    child: OnlineButton(),
                  ),
                if (snapshot.hasData &&
                    RiderModel.fromJson(snapshot.data!).rideId!.isNotEmpty)
                  Positioned(
                      bottom: 15,
                      left: 15,
                      right: 15,
                      child: RiderRequestCard(
                        rideId: RiderModel.fromJson(snapshot.data!).rideId!,
                      )),
                if (!snapshot.hasData ||
                    RiderModel.fromJson(snapshot.data!).rideId!.isEmpty)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(
                                0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child:
                          const Center(child: Text('Waiting for requests...')),
                    ),
                  ),
              ],
            );
          }),
    );
  }
}
