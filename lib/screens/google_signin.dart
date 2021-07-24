import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../authentication.dart';
import 'home_admin.dart';

class GoogleButton extends StatefulWidget {
  @override
  _GoogleButtonState createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<GoogleButton> {
  bool _isProcessing = false;

  String googleResult = "";

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.blueGrey, width: 3),
        ),
        color: Colors.white,
      ),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          primary: Colors.blueGrey.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.blueGrey, width: 3),
          ),
          elevation: 0,
        ),
        onPressed: () async {
          setState(() {
            _isProcessing = true;
          });
          await signInWithGoogle().then((result) async {
            print(result);
            googleResult = result == null ? "result=null" : result.email ?? "";

            if (result != null) {
              setState(() {
                _isProcessing = false;
              });
              Get.offAndToNamed(PageHomeAdmin.routeName);
            }
          }).catchError((error) {
            googleResult = 'Registration Error: $error';
            print('Registration Error: $error');
          });
          setState(() {
            _isProcessing = false;
          });
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: _isProcessing
              ? CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(
                    Colors.blueGrey,
                  ),
                )
              : Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image(
                          image: AssetImage("assets/images/google_logo.png"),
                          height: 30.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            'Sign-In with Google',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blueGrey,
                            ),
                          ),
                        )
                      ],
                    ),
                    googleResult == ""
                        ? const SizedBox.shrink()
                        : Text(googleResult)
                  ],
                ),
        ),
      ),
    );
  }
}
