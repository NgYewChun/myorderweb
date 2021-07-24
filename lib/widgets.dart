import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_controller.dart';
import 'screens/home.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final Function(String?)? validator;
  final VoidCallback? onClear;
  final TextInputType keyboardType;
  final TextStyle? textStyle;
  final int maxLines;

  const MyTextField(
      {Key? key,
      required this.controller,
      required this.hintText,
      required this.labelText,
      this.validator,
      this.onClear,
      this.keyboardType = TextInputType.text,
      this.textStyle,
      this.maxLines = 1})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            style: textStyle,
            maxLines: maxLines,
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
                hintStyle: TextStyle(fontSize: 12),
                errorMaxLines: 2,
                hintText: hintText,
                labelText: labelText),
            validator: (value) {
              return validator!(value);
            },
          ),
        ),
        onClear == null
            ? const SizedBox.shrink()
            : IconButton(
                onPressed: () {
                  controller.text = "";
                  onClear!();
                },
                icon: Icon(
                  Icons.backspace_outlined,
                  color: Colors.green,
                ),
              ),
      ],
    );
  }
}

class WgLogoutButton extends StatelessWidget {
  const WgLogoutButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: IconButton(
          tooltip: "Sign out",
          onPressed: () {
            AppController.signedInUser = "";
            Get.offAndToNamed(PageHome.routeName);
          },
          icon: Icon(Icons.logout)),
    );
  }
}
