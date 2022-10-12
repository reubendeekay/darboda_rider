import 'package:darboda_rider/constants.dart';
import 'package:darboda_rider/providers/auth_provider.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OnlineButton extends StatefulWidget {
  const OnlineButton({
    Key? key,
  }) : super(key: key);

  @override
  State<OnlineButton> createState() => _OnlineButtonState();
}

class _OnlineButtonState extends State<OnlineButton> {
  @override
  Widget build(BuildContext context) {
    final rider = Provider.of<AuthProvider>(context).rider;
    return SwipeButton.expand(
      borderRadius: BorderRadius.circular(5),
      thumb: const Icon(
        Icons.double_arrow_rounded,
        color: Colors.white,
      ),
      activeThumbColor: rider!.isOnline ? Colors.grey : const Color(0xff099766),
      activeTrackColor: kPrimaryColor,
      onSwipe: () async {
        await Provider.of<AuthProvider>(context, listen: false)
            .changeOnlineStatus(!rider.isOnline);
      },
      child: Text(
        rider.isOnline ? "Go Offline" : "Go Online",
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}
