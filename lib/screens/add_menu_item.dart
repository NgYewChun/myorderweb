import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myorderweb/app_controller.dart';
import 'package:myorderweb/firebase_api.dart';

import '../color_loader.dart';
import '../data_models.dart';
import '../helper.dart';
import '../widgets.dart';
import 'order_page.dart';
import 'view_controller.dart';

class PageAddMenuItem extends StatefulWidget {
  static String routeName = 'AddMenuItem';
  PageAddMenuItem({Key? key}) : super(key: key);

  @override
  _PageAddMenuItemState createState() => _PageAddMenuItemState();
}

class _PageAddMenuItemState extends State<PageAddMenuItem> {
  bool _initialized = false;
  bool _error = false;

  TextEditingController ctrlSection = TextEditingController();
  TextEditingController ctrlItemCode = TextEditingController();
  TextEditingController ctrlItemNameCn = TextEditingController();
  TextEditingController ctrlItemNameEn = TextEditingController();
  TextEditingController ctrlItemNameMy = TextEditingController();
  TextEditingController ctrlPrice = TextEditingController();
  TextEditingController ctrlSortOrder = TextEditingController();

  bool isChefRecommended = false;
  bool isSpicy = false;
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String imageUrl = "";

  // final Stream<QuerySnapshot> _menuStream = FirebaseApi.readMenu();
  @override
  void initState() {
    initializeFlutterFire();

    ctrlSection.text = "";
    ctrlItemCode.text = "";
    ctrlItemNameEn.text = "";
    ctrlItemNameCn.text = "";
    ctrlItemNameMy.text = "";
    ctrlPrice.text = "";
    ctrlSortOrder.text = "0";

    super.initState();
  }

  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        FirebaseApi.readAllMenu();
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
        appBar: AppBar(title: Text("Add Menu Item"), actions: [
          TextButton(
            child: Text("View Menu"),
            onPressed: () {
              Get.to(PageOrder(
                testView: true,
              ));
            },
          ),
          WgLogoutButton()
        ]),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Container(
                //alignment: Alignment.center,
                // color: Colors.greenAccent,
                padding: const EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Enter menu item details"),
                      buildItemDetails(context),
                      buildItemPicture(),
                      const SizedBox(
                        height: 20,
                      ),
                      buildAddItemButton(context),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
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

  Widget buildAddItemButton(BuildContext context) {
    return ElevatedButton(
        onPressed: () async {
          FocusScope.of(context).requestFocus(FocusNode());
          if (ctrlItemNameCn.text.isEmpty &&
              ctrlItemNameEn.text.isEmpty &&
              ctrlItemNameMy.text.isEmpty) {
            Helper.msgBox(context, "Item name is empty!",
                "You must at least enter 1 item name");

            return;
          }

          if (_imageFile == null) {
            await Helper.msgBoxYesNo(context,
                title: "No Image",
                content: "No image? are you sure?",
                option: ["YES", "NO"], callBack: (ans) {
              if (ans == "NO") return;
              imageUrl = "";
            });
          } else {
            imageUrl = await FirebaseApi.uploadMenuImageToFirebase(
                _imageFile, ctrlItemCode.text);
            print("url:$imageUrl");
          }
          int idx = AppController.menu
              .indexWhere((element) => element.itemCode == ctrlItemCode.text);
          if (idx != -1) {
            Helper.msgBox(context, "Duplicate Item Code!",
                "Item Code ${ctrlItemCode.text} already being used!");

            return;
          }

          MenuItem menuItem = MenuItem(
            dtCreated: DateTime.now(),
            id: "",
            section: ctrlSection.text,
            isSpicy: isSpicy,
            isChefRecommended: isChefRecommended,
            itemCode: ctrlItemCode.text,
            itemNameCn: ctrlItemNameCn.text,
            itemNameEn: ctrlItemNameEn.text,
            itemNameMy: ctrlItemNameMy.text,
            imageUrl: imageUrl,
            price: double.parse(ctrlPrice.text),
            sortOrder: int.parse(ctrlSortOrder.text),
          );
          Get.find<ViewController>().isBusy.value = true;

          String id = await FirebaseApi.createMenuItem(menuItem);
          print("new menu id:$id");
          Get.find<ViewController>().isBusy.value = false;
          Get.snackbar("Successfully Added new menu item", id);
        },
        child: Text("Add New Menu Item"));
  }

  Widget buildItemPicture() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Item Picture",
          ),
          _imageFile == null
              ? Container(width: 200, height: 200, color: Colors.grey)
              : Image.network(
                  _imageFile!.path, //Image.file(File(_imageFile!.path),
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover),
          TextButton(
              onPressed: () async {
                final pickedFile = await Helper.imageSelectorGallery(_picker);
                if (pickedFile == null) return;
                setState(() {
                  _imageFile = pickedFile;
                });
              },
              child: Text("Pick Photo")),
        ]);
  }

  Widget buildItemDetails(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        MyTextField(
            controller: ctrlSection,
            hintText: "Please Enter Menu Section",
            labelText: "Menu Section",
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Item Code cannot be empty';
              }
              return null;
            }),
        MyTextField(
            controller: ctrlItemNameCn,
            hintText: "Please Enter item Chinese name",
            labelText: "Item Chinese name",
            validator: null),
        MyTextField(
            controller: ctrlItemNameEn,
            hintText: "Please Enter item English name",
            labelText: "Item English name",
            validator: null),
        MyTextField(
            controller: ctrlItemNameMy,
            hintText: "Please Enter item Malay name",
            labelText: "Item Malay name",
            validator: null),
        MyTextField(
          controller: ctrlSortOrder,
          keyboardType: TextInputType.number,
          hintText: "Section display order",
          labelText: "Display Order",
          validator: (value) {
            if (int.tryParse(value ?? "") == null)
              return "Invalid dislay order";

            return null;
          },
        ),
        MyTextField(
            controller: ctrlPrice,
            keyboardType: TextInputType.number,
            hintText: "Please Enter item item Price",
            labelText: "Item Price",
            validator: null),
        Container(
          width: 250,
          child: CheckboxListTile(
            title: Text("Is Spicy?"),
            value: isSpicy,
            onChanged: (newValue) {
              setState(() {
                isSpicy = newValue ?? false;
              });
            },
            controlAffinity:
                ListTileControlAffinity.trailing, //  <-- leading Checkbox
          ),
        ),
        Container(
          width: 250,
          child: CheckboxListTile(
            title: Text("Is Chef Recommend?"),
            value: isChefRecommended,
            onChanged: (newValue) {
              setState(() {
                isChefRecommended = newValue ?? false;
              });
            },
            controlAffinity:
                ListTileControlAffinity.trailing, //  <-- leading Checkbox
          ),
        ),
        const SizedBox(
          height: 30,
        ),
      ],
    );
  }
}
