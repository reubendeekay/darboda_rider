import 'package:darboda_rider/constants.dart';
import 'package:darboda_rider/providers/request_provider.dart';
import 'package:darboda_rider/screens/trail/trail_screen.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';

import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';

class SwipeableButton extends StatefulWidget {
  const SwipeableButton({
    Key? key,
    required this.rideId,
  }) : super(key: key);
  final String rideId;

  @override
  State<SwipeableButton> createState() => _SwipeableButtonState();
}

class _SwipeableButtonState extends State<SwipeableButton> {
  @override
  Widget build(BuildContext context) {
    return SwipeButton.expand(
      borderRadius: BorderRadius.circular(5),
      thumb: const Icon(
        Icons.double_arrow_rounded,
        color: Colors.white,
      ),
      activeThumbColor: const Color(0xff099766),
      activeTrackColor: kPrimaryColor,
      onSwipe: () async {
        await Provider.of<RequestProvider>(context, listen: false)
            .acceptRequest(widget.rideId);
        Get.to(() => TrailScreen(
              rideId: widget.rideId,
            ));
      },
      child: const Text(
        "Accept",
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}
