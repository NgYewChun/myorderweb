import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'app_controller.dart';
import 'data_models.dart';

class FirebaseApi {
  static late FirebaseStorage _firebaseStorage;
  static late FirebaseAuth auth;

  static Future<String> createMenuItem(MenuItem menuItem) async {
    try {
      final docMenu = FirebaseFirestore.instance.collection("Menu").doc();
      menuItem.id = docMenu.id;
      await docMenu.set(menuItem.toJson());

      return docMenu.id;
    } catch (ex) {
      print(ex.toString());
    }

    return "";
  }

  static Future<bool> updateMenuItem(Map<String, dynamic> menuItem) async {
    try {
      final docMenu =
          FirebaseFirestore.instance.collection("Menu").doc(menuItem['id']);
      await docMenu.update(menuItem);

      return true;
    } catch (ex) {
      print(ex.toString());
    }

    return false;
  }

  static Future<String> addBanner(MyBanner banner, XFile? file) async {
    try {
      final docBanner = FirebaseFirestore.instance.collection("Banner").doc();
      banner.id = docBanner.id;
      banner.imageUrl = await uploadBannerImageToFirebase(file, banner.id);
      await docBanner.set(banner.toJson());

      return docBanner.id;
    } catch (ex) {
      print(ex.toString());
    }

    return "";
  }

  static void init() {
    _firebaseStorage =
        FirebaseStorage.instanceFor(bucket: 'gs://myorder-faea6.appspot.com');

    auth = FirebaseAuth.instance;
  }

//https://firebase.flutter.dev/docs/firestore/usage
  static Stream<QuerySnapshot> readMenu() {
    return FirebaseFirestore.instance
        .collection("Menu")
        .orderBy("sortOrder")
        .snapshots();
  }

  static Future<Map<String, dynamic>?> checkUser(email) async {
    try {
      var result = await FirebaseFirestore.instance
          .collection('User')
          .where('email', isEqualTo: email)
          .get();

      return result.docs.first.data();
    } catch (ex) {
      print("checkUser exception:" + ex.toString());
    }

    return null;
  }

  static Stream<QuerySnapshot> readBanner() {
    return FirebaseFirestore.instance
        .collection("Banner")
        .orderBy("sortOrder")
        .snapshots();
  }

  static Future<bool> deleteBannerRecord(docId) async {
    try {
      await FirebaseFirestore.instance.collection('Banner').doc(docId).delete();
      return true;
    } catch (ex) {
      print("deleteBannerRecord exception:" + ex.toString());
    }

    return false;
  }

  static Future<void> updateImageUrl(
      String menuItemId, String newImageUrl) async {
    CollectionReference menuItems =
        FirebaseFirestore.instance.collection('Menu');

    return await menuItems
        .doc(menuItemId)
        .update({'imageUrl': newImageUrl})
        .then((value) => print("newImageUrl Updated"))
        .catchError((error) => print("Failed to update newImageUrl: $error"));
  }

  static Future<void> readAllMenu() async {
    CollectionReference menu = FirebaseFirestore.instance.collection('Menu');
    menu.orderBy("sortOrder").get().then((value) {
      value.docs.map((DocumentSnapshot document) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        AppController.addMenuItem(document.id, data);
      });
    });
  }

  static Future<String> uploadMenuImageToFirebase(
      XFile? file, String itemCode) {
    String filename =
        itemCode.replaceAll(" ", "").replaceAll("-", "_") + ".jpg";
    return uploadImageToFirebase(file, "menuItemPicture", filename);
  }

  static Future<String> uploadBannerImageToFirebase(XFile? file, String title) {
    String filename = title.replaceAll(" ", "").replaceAll("-", "_") + ".jpg";
    return uploadImageToFirebase(file, "banners", filename);
  }

  static Future<String> uploadImageToFirebase(
      XFile? file, String folder, String filename) async {
    String uploadedPhotoUrl = "";
    try {
      Reference _reference = _firebaseStorage.ref().child('$folder/$filename');
      await _reference
          .putData(
        await file!.readAsBytes(),
        SettableMetadata(contentType: 'image/jpeg'),
      )
          .whenComplete(() async {
        await _reference.getDownloadURL().then((value) {
          uploadedPhotoUrl = value;
        });
      });
    } catch (ex) {
      print("uploadImageToFirebase exception:" + ex.toString());
    }
    return uploadedPhotoUrl;
  }

  static Future<bool> deleteMenuImageFromFirebase(String itemCode) async {
    String filename =
        itemCode.replaceAll(" ", "").replaceAll("-", "_") + ".jpg";
    return deleteImageFromFirebase("menuItemPicture", filename);
  }

  static Future<bool> deleteBannerImage(String fileid) async {
    String filename = fileid.replaceAll(" ", "").replaceAll("-", "_") + ".jpg";
    return deleteImageFromFirebase("banners", filename);
  }

  static Future<bool> deleteImageFromFirebase(
      String folder, String filename) async {
    try {
      Reference _reference = _firebaseStorage.ref().child('$folder/$filename');
      await _reference.delete();
      return true;
    } catch (ex) {
      print("deleteImageFromFirebase exception:" + ex.toString());
    }

    return false;
  }
}
