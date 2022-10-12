// ignore_for_file: use_build_context_synchronously

import 'package:darboda_rider/providers/auth_provider.dart';
import 'package:darboda_rider/providers/location_provider.dart';
import 'package:darboda_rider/screens/auth/register_driver.dart';
import 'package:darboda_rider/screens/home/homepage.dart';
import 'package:darboda_rider/screens/trail/trail_screen.dart';

import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class InitialLoadingScreen extends StatefulWidget {
  const InitialLoadingScreen({super.key});

  @override
  State<InitialLoadingScreen> createState() => _InitialLoadingScreenState();
}

class _InitialLoadingScreenState extends State<InitialLoadingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await Provider.of<AuthProvider>(context, listen: false).getCurrentUser();
      await Provider.of<LocationProvider>(context, listen: false)
          .getCurrentLocation();

      final user = Provider.of<AuthProvider>(context, listen: false).user;

      if (user!.isDriver) {
        final driver = Provider.of<AuthProvider>(context, listen: false).rider!;

        if (driver.rideId!.isNotEmpty) {
          Get.offAll(() => TrailScreen(
                rideId: driver.rideId!,
              ));
        } else {
          Get.offAll(() => const Homepage());
        }
      } else {
        Get.off(() => const RegisterDriverScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset('assets/rider.json'),
      ),
    );
  }
}
