import 'package:darboda_rider/constants.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';

import 'package:iconsax/iconsax.dart';
import 'package:file_picker/file_picker.dart';

class AddDocumentsWidget extends StatefulWidget {
  const AddDocumentsWidget({Key? key, required this.onImagesAdded})
      : super(key: key);
  final Function(List<File>) onImagesAdded;

  @override
  // ignore: library_private_types_in_public_api
  _AddDocumentsWidgetState createState() => _AddDocumentsWidgetState();
}

class _AddDocumentsWidgetState extends State<AddDocumentsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController loadingController;

  List<File> files = [];

  List<PlatformFile> platformFiles = [];

  selectFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      for (var file in result.paths) {
        files.add(File(file!));
        final platformFile = PlatformFile(
          name: file.split('/').last,
          path: file,
          size: File(file).lengthSync(),
          bytes: await File(file).readAsBytes(),
          identifier: file,
          readStream: File(file).openRead(),
        );
        platformFiles.add(platformFile);
        setState(() {});
      }

      widget.onImagesAdded(files);
    } else {
      // User canceled the picker
    }

    loadingController.forward();
  }

  @override
  void initState() {
    loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
        setState(() {});
      });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Upload Documents',
          style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          '''Include the following documents:.
          1. Your ID card.
          2. Your driving license.
          3. Your vehicle registration documents.''',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        const SizedBox(
          height: 20,
        ),
        GestureDetector(
          onTap: selectFile,
          child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
              child: DottedBorder(
                borderType: BorderType.RRect,
                radius: const Radius.circular(10),
                dashPattern: const [10, 4],
                strokeCap: StrokeCap.round,
                color: kPrimaryColor.withOpacity(0.5),
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                      color: Colors.blue.shade50.withOpacity(.3),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Iconsax.folder_open,
                        color: kPrimaryColor,
                        size: 40,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Select Documents',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
              )),
        ),
        files.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...List.generate(
                    platformFiles.length,
                    ((index) => Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white,
                              boxShadow: const []),
                          child: Row(
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    'assets/images/doc.png',
                                    width: 70,
                                    fit: BoxFit.cover,
                                  )),
                              const SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      platformFiles[index].name,
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.black),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      '${(platformFiles[index].size / 1024).ceil()} KB',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade500),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                        height: 5,
                                        clipBehavior: Clip.hardEdge,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.green.shade50,
                                        ),
                                        child: LinearProgressIndicator(
                                          value: loadingController.value,
                                          color: kPrimaryColor,
                                        )),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                        )),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              )
            : Container(),
      ],
    );
  }
}
