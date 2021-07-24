import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myorderweb/constants.dart';
import 'package:myorderweb/firebase_api.dart';

import '../app_controller.dart';
import '../color_loader.dart';
import '../helper.dart';
import '../widgets.dart';
import 'add_menu_item.dart';
import 'view_controller.dart';

class PageEditMenu extends StatefulWidget {
  static String routeName = 'EditMenu';

  PageEditMenu({Key? key}) : super(key: key);

  @override
  _PageEditMenuState createState() => _PageEditMenuState();
}

class _PageEditMenuState extends State<PageEditMenu> {
  bool _initialized = false;
  bool _error = false;

  final Stream<QuerySnapshot> _menuStream = FirebaseApi.readMenu();
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
          title: Text("Edit Menu"),
          actions: [
            IconButton(
                onPressed: () {
                  Get.to(PageAddMenuItem());
                },
                icon: Icon(Icons.add_box_outlined)),
            WgLogoutButton()
          ],
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  width: 400,
                  height: MediaQuery.of(context).size.height,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _menuStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Something went wrong');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text("Loading....hang on");
                      }

                      String section = "";
                      return ListView(
                        physics: BouncingScrollPhysics(),
                        children: [
                          ...buildMenuItems(
                              snapshot.data!.docs, section, context),
                          const SizedBox(
                            height: 100,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            Obx(() => (Get.find<ViewController>().isBusy.value)
                ? LoadingMask(
                    loadingMessage: "Request in process, please wait a moment",
                  )
                : Container()),
          ],
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  List<Column> buildMenuItems(
      List<QueryDocumentSnapshot> docs, String section, BuildContext context) {
    return docs.map((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;

      AppController.addMenuItem(document.id, data);

      Widget menuItem = WgMenuItem(data: data);
      if (section != data['section']) {
        section = data['section'];
        return Column(
          children: [
            Text(
              section,
              style: Theme.of(context).textTheme.headline6,
            ),
            menuItem
          ],
        );
      } else
        return Column(children: [menuItem]);
    }).toList();
  }
}

class WgMenuItem extends StatefulWidget {
  const WgMenuItem({
    Key? key,
    required this.data,
  }) : super(key: key);

  final Map<String, dynamic> data;

  @override
  _WgMenuItemState createState() => _WgMenuItemState();
}

class _WgMenuItemState extends State<WgMenuItem> {
  bool bNewPhoto = false;
  XFile? _imageFile;
  String imageUrl = "";

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(color: Colors.white);
    return Container(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(children: [
        Expanded(
            flex: 3,
            child: ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.data['itemCode'],
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => editMenuItem(context, widget.data),
                    child: Text("Edit"),
                  )
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.data['itemNameCn'],
                    style: textStyle,
                  ),
                  Text(widget.data['itemNameEn'], style: textStyle),
                  Text("RM ${widget.data['price']}", style: textStyle),
                ],
              ),
            )),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              buildImage(),
              TextButton(
                child: Text(bNewPhoto ? "Update Photo" : "Change photo"),
                onPressed: () async {
                  if (!bNewPhoto) {
                    //change photo
                    final pickedFile =
                        await Helper.imageSelectorGallery(ImagePicker());
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
                    await FirebaseApi.deleteMenuImageFromFirebase(
                        widget.data['itemCode']);

                    imageUrl = await FirebaseApi.uploadMenuImageToFirebase(
                        _imageFile, widget.data['itemCode']);
                    if (imageUrl.isNotEmpty) {
                      await FirebaseApi.updateImageUrl(
                          widget.data['id'], imageUrl);
                      setState(() {
                        bNewPhoto = false;
                        _imageFile = null;
                      });
                    }

                    viewController.isBusy.value = false;
                  }
                },
              ),
            ],
          ),
        ),
      ]),
    );
  }

  void editMenuItem(BuildContext context, Map<String, dynamic> data) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return EditMenuItemDialog(
            data: data,
            onRefresh: () => setState(() {}),
          );
        });
  }

  Widget buildImage() {
    if (_imageFile == null) {
      final imageUrl = widget.data['imageUrl'] ?? "";
      return (imageUrl == "")
          ? Image.asset("assets/images/no_image.png")
          : Image.network(imageUrl);
    } else
      return Image.network(_imageFile!.path);
  }
}

class EditMenuItemDialog extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback onRefresh;
  const EditMenuItemDialog(
      {Key? key, required this.data, required this.onRefresh})
      : super(key: key);

  @override
  _EditMenuItemDialogState createState() => _EditMenuItemDialogState();
}

class _EditMenuItemDialogState extends State<EditMenuItemDialog> {
  TextEditingController ctrlSection = TextEditingController();
  TextEditingController ctrlItemCode = TextEditingController();
  TextEditingController ctrlItemNameCn = TextEditingController();
  TextEditingController ctrlItemNameEn = TextEditingController();
  TextEditingController ctrlItemNameMy = TextEditingController();
  TextEditingController ctrlPrice = TextEditingController();

  @override
  void initState() {
    super.initState();

    ctrlSection.text = widget.data['section'];
    ctrlItemCode.text = widget.data['itemCode'];
    ctrlItemNameEn.text = widget.data['itemNameEn'];
    ctrlItemNameCn.text = widget.data['itemNameCn'];
    ctrlItemNameMy.text = widget.data['itemNameMy'];
    ctrlPrice.text = widget.data['price'].toString();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  Widget dialogContent(BuildContext context) {
    const double contentWidth = 300;
    return SingleChildScrollView(
      child: Container(
        color: secondaryColor,
        width: contentWidth,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          children: [
            Text(
              "Edit Menu Item",
              style: TextStyle(color: Colors.white38),
            ),
            MyTextField(
                controller: ctrlSection,
                hintText: "Please Enter Menu Section",
                labelText: "Menu Section",
                onClear: () => setState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter menu section';
                  }
                  return null;
                }),
            MyTextField(
                controller: ctrlItemCode,
                hintText: "Please enter item code",
                labelText: "Item Code",
                onClear: () => setState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Item Code cannot be empty';
                  }
                  return null;
                }),
            MyTextField(
                maxLines: 2,
                textStyle: TextStyle(fontSize: 15),
                controller: ctrlItemNameEn,
                hintText: "Please Enter item English name",
                labelText: "Item English name",
                onClear: () => setState(() {}),
                validator: null),
            MyTextField(
                controller: ctrlItemNameCn,
                hintText: "Please Enter item Chinese name",
                labelText: "Item Chinese name",
                onClear: () => setState(() {}),
                validator: null),
            MyTextField(
                controller: ctrlItemNameMy,
                maxLines: 2,
                hintText: "Please Enter item Malay name",
                labelText: "Item Malay name",
                onClear: () => setState(() {}),
                validator: null),
            MyTextField(
                controller: ctrlPrice,
                keyboardType: TextInputType.number,
                hintText: "Please Enter item item Price",
                labelText: "Price",
                onClear: () => setState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  return null;
                }),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  child: Text("Close"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: kButtonGold,
                ),
                ElevatedButton(
                    child: Text("Save Chanes"),
                    onPressed: () {
                      if (!AppController.validateMenuItemCode(
                          ctrlItemCode.text, widget.data['id'])) {
                        Helper.msgBox(context, "Invalid Item Code",
                            "Item Code: ${ctrlItemCode.text} already being used");
                        return;
                      }
                      widget.data['section'] = ctrlSection.text;
                      widget.data['itemNameCn'] = ctrlItemNameCn.text;
                      widget.data['itemNameEn'] = ctrlItemNameEn.text;
                      widget.data['itemNameMy'] = ctrlItemNameMy.text;
                      widget.data['itemCode'] = ctrlItemCode.text;
                      widget.data['price'] = double.parse(ctrlPrice.text);

                      Get.find<ViewController>().isBusy.value = true;
                      FirebaseApi.updateMenuItem(widget.data);
                      Get.find<ViewController>().isBusy.value = false;
                      widget.onRefresh();
                      Navigator.pop(context);
                    },
                    style: kButtonGold),
              ],
            )
          ],
        ),
      ),
    );
  }
}
