import 'dart:io';

import 'package:darboda_rider/loading_screen.dart';
import 'package:darboda_rider/models/driver_model.dart';
import 'package:darboda_rider/providers/auth_provider.dart';
import 'package:darboda_rider/providers/rider_provider.dart';
import 'package:darboda_rider/screens/auth/add_documents_widget.dart';
import 'package:darboda_rider/widgets/custom_textfield.dart';
import 'package:darboda_rider/widgets/primary_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';

class RegisterDriverScreen extends StatefulWidget {
  const RegisterDriverScreen({super.key});

  @override
  State<RegisterDriverScreen> createState() => _RegisterDriverScreenState();
}

class _RegisterDriverScreenState extends State<RegisterDriverScreen> {
  final nameController = TextEditingController();

  final emailController = TextEditingController();
  final idController = TextEditingController();
  final typeController = TextEditingController();
  final plateNumberController = TextEditingController();
  final colorController = TextEditingController();
  List<File> files = [];
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete your profile'),
        elevation: 0.4,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(15),
            children: [
              const Text(
                'Personal Information',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 10,
              ),
              CustomTextField(
                  controller: nameController, hintText: 'Legal Name'),
              const SizedBox(
                height: 10,
              ),
              CustomTextField(
                  controller: emailController, hintText: 'Email Address'),
              const SizedBox(
                height: 10,
              ),
              CustomTextField(
                  controller: idController,
                  hintText: 'National ID/Passport No.'),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Vehicle Information',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 10,
              ),
              CustomTextField(
                  controller: typeController, hintText: 'Bodaboda Model'),
              const SizedBox(
                height: 10,
              ),
              CustomTextField(
                  controller: plateNumberController, hintText: 'Plate Number'),
              const SizedBox(
                height: 10,
              ),
              CustomTextField(
                  controller: colorController, hintText: 'Bodaboda Color'),
              const SizedBox(
                height: 20,
              ),
              AddDocumentsWidget(onImagesAdded: (val) {
                setState(() {
                  files = val;
                });
              }),
              if (files.isNotEmpty)
                const SizedBox(
                  height: 60,
                ),
            ],
          ),
          AnimatedPositioned(
            bottom: files.isNotEmpty ? 15 : -100,
            left: 15,
            right: 15,
            duration: const Duration(milliseconds: 800),
            child: PrimaryButton(
                text: 'Submit',
                isLoading: isLoading,
                onTap: () async {
                  final user =
                      Provider.of<AuthProvider>(context, listen: false).user!;
                  final rider = RiderModel(
                    name: nameController.text,
                    nationalId: idController.text,
                    phoneNumber: user.phoneNumber,
                    profilePic: user.profilePic,
                    vehicleColor: colorController.text,
                    vehicleModel: typeController.text,
                    vehicleNumber: plateNumberController.text,
                    email: emailController.text,
                  );
                  setState(() {
                    isLoading = true;
                  });
                  try {
                    await Provider.of<RiderProvider>(context, listen: false)
                        .registerDriver(rider, files);
                    setState(() {
                      isLoading = false;
                    });
                    Get.to(() => const InitialLoadingScreen());
                  } catch (e) {
                    if (kDebugMode) {
                      print(e);
                    }
                    setState(() {
                      isLoading = false;
                    });
                  }
                }),
          )
        ],
      ),
    );
  }
}
