import 'package:cached_network_image/cached_network_image.dart';
import 'package:darboda_rider/constants.dart';
import 'package:darboda_rider/providers/auth_provider.dart';
import 'package:darboda_rider/screens/auth/edit_driver_screen.dart';
import 'package:darboda_rider/screens/history/my_rides_screen.dart';
import 'package:darboda_rider/screens/profile/widgets/bar_chat.dart';
import 'package:darboda_rider/screens/profile/widgets/support_widget.dart';
import 'package:darboda_rider/screens/trail/weekly_payment_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final rider = Provider.of<AuthProvider>(context, listen: false).rider!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(children: [
        Container(
          height: size.height - kToolbarHeight,
          width: size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                kPrimaryColor,
                kPrimaryColor,
                Colors.grey[50]!,
                Colors.grey[50]!,
                Colors.grey[50]!,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        ListView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage:
                        CachedNetworkImageProvider(rider.profilePic!),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rider.name!,
                        ),
                        Text(rider.isOnline ? 'Active' : 'Offline',
                            style: TextStyle(
                                color:
                                    rider.isOnline ? Colors.green : Colors.grey,
                                fontSize: 12))
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const EditDriverScreen());
                    },
                    child: Container(
                      width: 120,
                      height: 38,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: kPrimaryColor,
                      ),
                      child: const Center(
                          child: Text(
                        'Edit',
                        style: TextStyle(color: Colors.white),
                      )),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              width: size.width,
              height: size.height * 0.4,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(5)),
              child: const BarChart(),
            ),
            const SizedBox(
              height: 15,
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Settings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...List.generate(
              settings.length,
              (index) => settingTile(settings[index]),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        )
      ]),
    );
  }
}

Widget settingTile(Map<String, dynamic> data) {
  return ListTile(
    leading: Icon(
      data['icon'],
      size: 24,
    ),
    title: Text(
      data['title'],
    ),
    onTap: () {
      if (data['title'] == 'Support') {
        Get.bottomSheet(const SupportWidget(),
            isDismissible: true,
            backgroundColor: Colors.white,
            isScrollControlled: true);
      } else {
        data['onTap']();
      }
    },
    trailing: const Icon(
      CupertinoIcons.chevron_right,
      size: 16,
    ),
  );
}

List<Map<String, dynamic>> settings = [
  {
    'title': 'Payment',
    'icon': Iconsax.card,
    'onTap': () {
      Get.to(() => const WeeklyPaymentScreen());
    },
  },
  {
    'title': 'My Rides',
    'icon': Icons.motorcycle,
    'onTap': () {
      Get.to(() => const MyRidesScreen());
    },
  },
  {
    'title': 'Support',
    'icon': Iconsax.info_circle,
    'onTap': () {},
  },
  {
    'title': 'Logout',
    'icon': Iconsax.logout,
    'onTap': () {
      FirebaseAuth.instance.signOut().then(
            (value) => Get.offAllNamed('/'),
          );
    },
  },
];
