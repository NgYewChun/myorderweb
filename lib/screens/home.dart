import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../color_loader.dart';
import '../firebase_api.dart';
import '../helper.dart';
import 'order_page.dart';
import 'signin.dart';
import 'view_controller.dart';

class PageHome extends StatefulWidget {
  static String routeName = 'Home';

  const PageHome({Key? key}) : super(key: key);

  @override
  _PageHomeState createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  bool _initialized = false;
  bool _error = false;
  final Stream<QuerySnapshot> _bannerStream = FirebaseApi.readBanner();

  @override
  void initState() {
    initializeFlutterFire();
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
          title: Text("Home"),
          leading: IconButton(
              onPressed: () {
                Get.to(PageSignIn());
              },
              icon: Icon(Icons.login)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: TextButton(
                child: Text(
                  "Place Order",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Get.to(PageOrder());
                },
              ),
            ),
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
                    return Text('Something went wrong, unable to load banners');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading...please hold on a second");
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

    return data.docs.map((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;

      final imageUrl = data['imageUrl'] ?? "";
      return Column(
        children: [
          Text(
            data['title'],
            style: Theme.of(context).textTheme.headline5,
          ),
          Container(
            alignment: Alignment.center,
            constraints: BoxConstraints(maxWidth: 500),
            child: (imageUrl == "")
                ? Image.asset("assets/images/no_image.png")
                : Image.network(imageUrl),
          ),
        ],
      );
    }).toList();
  }
}
