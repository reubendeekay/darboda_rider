import 'package:darboda_rider/loading_screen.dart';
import 'package:darboda_rider/screens/home/homepage.dart';
import 'package:darboda_rider/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CancelledRide extends StatefulWidget {
  const CancelledRide({super.key});

  @override
  State<CancelledRide> createState() => _CancelledRideState();
}

class _CancelledRideState extends State<CancelledRide> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      showBottomSheet(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          context: context,
          builder: (ctx) => const CancelledRideWidget());
      Future.delayed(const Duration(seconds: 10), () {
        Navigator.of(context).pop();
        Get.offAll(() => const InitialLoadingScreen());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class CancelledRideWidget extends StatelessWidget {
  const CancelledRideWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              height: 160.h,
              child: Lottie.asset('assets/cancelled.json', repeat: false),
            ),
            const Text(
              'Ride Cancelled',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              ('The current ride has been cancelled.\n Please try again later'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(
              height: 30,
            ),
            PrimaryButton(
                text: 'Okay',
                onTap: () {
                  Navigator.of(context).pop();
                  Get.offAll(() => const InitialLoadingScreen());
                })
          ],
        ),
      ),
    );
  }
}

class BackHome extends StatefulWidget {
  const BackHome({super.key});

  @override
  State<BackHome> createState() => _BackHomeState();
}

class _BackHomeState extends State<BackHome> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      Get.offAll(() => const Homepage());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
