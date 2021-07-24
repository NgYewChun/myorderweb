import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'color_loader.dart';
import 'constants.dart';

class Helper {
  static dynamic fromDateTimeToJson(DateTime? date) {
    if (date == null) return null;

    return date.toUtc();
  }

  static DateTime toDateTime(Timestamp value) {
    return value.toDate();
  }

  static double toMoney(double num) {
    return double.parse((num).toStringAsFixed(2));
  }

  static void msgBox(BuildContext context, String title, String content) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text(title),
            content: new Text(content),
            actions: <Widget>[
              new ElevatedButton(
                  style: kButtonGold,
                  onPressed: () => Navigator.of(context).pop(),
                  child: new Text("OK"))
            ],
          );
        });
  }

  static Future<void> msgBoxYesNo(BuildContext context,
      {required String title,
      required String content,
      required List<String> option,
      required void Function(String) callBack}) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogYesNo(
            title: title,
            description: content,
            option: option,
            callBack: (yesno) => callBack(yesno),
          );
        });
  }

  static StreamTransformer transformer<T>(
          T Function(Map<String, dynamic> json) fromJson) =>
      StreamTransformer<QuerySnapshot, List<T>>.fromHandlers(
        handleData: (QuerySnapshot data, EventSink<List<T>> sink) {
          final snaps = data.docs.map((doc) => doc.data()).toList();
          final objects = snaps.map((obj) {
            Map<String, dynamic> json = obj as Map<String, dynamic>;
            return fromJson(json);
          }).toList();

          sink.add(objects);
        },
      );

  static Future<XFile?> imageSelectorGallery(ImagePicker picker) async {
    try {
      final pickedFile = await picker.pickImage(
          source: ImageSource.gallery, maxHeight: 480, maxWidth: 640);
      return pickedFile;
    } catch (e) {
      Get.snackbar("Pick File Error", e.toString());
    }
    return null;
  }
}

// ignore: must_be_immutable
class DialogYesNo extends StatelessWidget {
  final String title, description;

  List<String> option;
  final void Function(String) callBack;
  DialogYesNo(
      {required this.callBack,
      required this.option,
      required this.title,
      required this.description});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Consts.padding)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          constraints: BoxConstraints(maxWidth: 500),
          padding: Consts.dlgPadding,
          margin: EdgeInsets.only(top: Consts.avatarRadius),
          decoration: Consts.dlgBoxDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              DlgTitle(title: title),
              SizedBox(height: 16.0),
              DlgText(description: description),
              SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: kButtonGold,
                    onPressed: () {
                      Navigator.of(context).pop(); // To close the dialog
                      callBack(option[0]);
                    },
                    child: Text(option[0],
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton(
                    style: kButtonGold,
                    onPressed: () {
                      Navigator.of(context).pop(); // To close the dialog
                      callBack(option[1]);
                    },
                    child: Text(option[1],
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          left: Consts.padding,
          right: Consts.padding,
          child: CircleAvatar(
            backgroundColor: Colors.indigo,
            radius: Consts.avatarRadius,
            child: Image.asset('assets/images/question.png'),
          ),
        ),
      ],
    );
  }
}

class DlgText extends StatelessWidget {
  const DlgText({
    Key? key,
    required this.description,
  }) : super(key: key);

  final String description;

  @override
  Widget build(BuildContext context) {
    return Text(
      description,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16.0,
      ),
    );
  }
}

class DlgTitle extends StatelessWidget {
  const DlgTitle({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class LoadingMask extends StatelessWidget {
  final String? loadingMessage;
  const LoadingMask({
    Key? key,
    this.loadingMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Positioned(
      left: 0,
      top: 0,
      height: size.height,
      width: size.width,
      child: Container(
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
                  child: Text(
                      loadingMessage ?? "Request in process, please wait",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15))),
            ),
          ],
        ),
      ),
    );
  }
}
