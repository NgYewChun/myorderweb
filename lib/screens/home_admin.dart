import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../app_controller.dart';
import '../color_loader.dart';
import '../data_models.dart';
import '../firebase_api.dart';
import '../helper.dart';
import '../widgets.dart';
import 'edit_menu.dart';
import 'home.dart';
import 'view_controller.dart';

class PageHomeAdmin extends StatefulWidget {
  static String routeName = 'HomeAdmin';

  const PageHomeAdmin({Key? key}) : super(key: key);

  @override
  _PageHomeAdminState createState() => _PageHomeAdminState();
}

class _PageHomeAdminState extends State<PageHomeAdmin> {
  bool _initialized = false;
  bool _error = false;
  XFile? _imageFile;

  final Stream<QuerySnapshot> _bannerStream = FirebaseApi.readBanner();

  bool bNewPhoto = false;
  TextEditingController ctrlNewBannnerTitle = TextEditingController();
  TextEditingController ctrlSortOrder = TextEditingController();

  @override
  void initState() {
    initializeFlutterFire();
    ctrlSortOrder.text = "0";
    super.initState();
  }

  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Container(
        child: Text("Error loading firebase"),
      );
    }

    // Show a loader until FlutterFire is initialized
    if (!_initialized) {
      return Container(
        color: Colors.black.withOpacity(0.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ColorLoader3(
              radius: 15.0,
              dotRadius: 6.0,
            ),
            Center(
              child: Material(
                  type: MaterialType.transparency,
                  child: Text("loading....hold on a second..",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15))),
            ),
          ],
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("Edit Banner"),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: TextButton(
                child: Text(
                  "Edit Menu",
                ),
                onPressed: () {
                  Get.to(PageEditMenu());
                },
              ),
            ),
            WgLogoutButton(),
          ],
        ),
        body: Stack(fit: StackFit.expand, children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(10),
              constraints: BoxConstraints(maxWidth: 800),
              width: MediaQuery.of(context).size.width,
              child: StreamBuilder<QuerySnapshot>(
                stream: _bannerStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading menu");
                  }
                  print("legth:${snapshot.data!.docs.length}");
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        (snapshot.data!.docs.isEmpty)
                            ? Text("Record empty!",
                                style: Theme.of(context).textTheme.headline6)
                            : const SizedBox.shrink(),
                        ...buildBannerList(snapshot.data, context),
                        Text("Add new Banner",
                            style: Theme.of(context).textTheme.headline6),
                        buildNewBanner(),
                        buildSelectPhotoButton(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Obx(() => (Get.find<ViewController>().isBusy.value)
              ? LoadingMask(
                  loadingMessage: "Request in process, please wait a moment",
                )
              : Container()),
        ]));
  }

  List<Widget> buildBannerList(
      QuerySnapshot<Object?>? data, BuildContext context) {
    if (data!.docs.isEmpty) return [];

    ctrlSortOrder.text = (data.docs.length + 1).toString();
    return data.docs.map((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;

      final imageUrl = data['imageUrl'] ?? "";
      return Column(
        children: [
          Text(
            "${data['title']} (${data['sortOrder']})",
            style: Theme.of(context).textTheme.headline6,
          ),
          Container(
            constraints: BoxConstraints(maxWidth: 500),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Created at ${Helper.toDateTime(data['dtCreated']).toString().substring(0, 16)}",
                ),
                TextButton(
                  child: Text("Delete"),
                  onPressed: () {
                    Helper.msgBoxYesNo(context,
                        title: "Delete Banner",
                        content:
                            "Confirm to remove this Banner(${data['title']})?",
                        option: ["YES", "NO"], callBack: (ans) async {
                      if (ans == "NO") return;

                      ViewController viewController =
                          Get.find<ViewController>();
                      viewController.isBusy.value = true;
                      bool bOK =
                          await FirebaseApi.deleteBannerImage(data['id']);
                      if (bOK)
                        bOK = await FirebaseApi.deleteBannerRecord(data['id']);
                      viewController.isBusy.value = false;
                      if (bOK) {
                        Get.snackbar("Banner Deleted", "");
                      } else
                        Get.snackbar("Error!! failed to delete  banner!", "");
                    });
                  },
                )
              ],
            ),
          ),
          Container(
            constraints: BoxConstraints(maxWidth: 500),
            alignment: Alignment.center,
            child:
                (imageUrl == "") ? SizedBox.shrink() : Image.network(imageUrl),
            color: Colors.grey.shade300,
          ),
        ],
      );
    }).toList();
  }

  Widget buildSelectPhotoButton() {
    return TextButton(
      child: Text(bNewPhoto ? "Upload Photo" : "Select Photo"),
      onPressed: () async {
        if (!bNewPhoto) {
          //change photo
          final pickedFile = await Helper.imageSelectorGallery(ImagePicker());
          if (pickedFile == null) return;
          setState(() {
            print("new photo path:" + pickedFile.path);
            _imageFile = pickedFile;
            bNewPhoto = !bNewPhoto;
          });
        } else {
          //update photo
          ViewController viewController = Get.find<ViewController>();
          viewController.isBusy.value = true;

          MyBanner banner = MyBanner(
              id: "",
              title: ctrlNewBannnerTitle.text,
              sortOrder: int.parse(ctrlSortOrder.text),
              dtCreated: DateTime.now(),
              imageUrl: "");
          final String bannerID =
              await FirebaseApi.addBanner(banner, _imageFile);
          if (bannerID.isNotEmpty) {
            Get.snackbar("Add New Banner", "Successful added new banner");
            setState(() {
              bNewPhoto = false;
              _imageFile = null;
              ctrlNewBannnerTitle.text = "";
              ctrlSortOrder.text = "0";
            });
          } else
            Get.snackbar("Error! Failed to add new banner", "Error");

          viewController.isBusy.value = false;
        }
      },
    );
  }

  Widget buildNewBanner() {
    return Column(
      children: [
        Container(
            alignment: Alignment.center,
            width: 480,
            height: 500,
            color: Colors.grey.shade100,
            child: _imageFile == null
                ? const Text("Pick a banner photo")
                : Image.network(_imageFile!.path)),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: MyTextField(
                  controller: ctrlNewBannnerTitle,
                  hintText: "Enter banner title",
                  labelText: "Banner Title",
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return "You must enter a title for this banner";
                    }
                    return null;
                  },
                  onClear: () {
                    setState(() {});
                  }),
            ),
            Expanded(
              flex: 1,
              child: MyTextField(
                  controller: ctrlSortOrder,
                  hintText: "Display order",
                  labelText: "Display Order",
                  onClear: () {
                    setState(() {});
                  }),
            ),
          ],
        )
      ],
    );
  }
}
