import 'package:cached_network_image/cached_network_image.dart';
import 'package:darboda_rider/providers/auth_provider.dart';
import 'package:darboda_rider/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Get.to(() => const ProfileScreen());
            },
            child: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(auth.user!.profilePic!),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(25, 8, 8, 8),
            decoration: BoxDecoration(
                color: auth.rider!.isOnline
                    ? const Color(0xff099766)
                    : Colors.grey,
                borderRadius: BorderRadius.circular(50)),
            child: Row(
              children: [
                Text(
                  auth.rider!.isOnline ? 'Online' : 'Offline',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(
                  width: 15,
                ),
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.grey[50],
                  child: Icon(
                    Icons.motorcycle,
                    color: auth.rider!.isOnline
                        ? const Color(0xff099766)
                        : Colors.grey,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(
                Iconsax.notification,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
