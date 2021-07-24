import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myorderweb/constants.dart';

import '../app_controller.dart';
import '../firebase_api.dart';
import '../helper.dart';
import 'home_admin.dart';
import 'view_controller.dart';

class PageSignIn extends StatelessWidget {
  static const String routeName = "/AdminSignin";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Sign-In")),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AuthDialog(),
          ),
          Obx(() => (Get.find<ViewController>().isBusy.value)
              ? LoadingMask(
                  loadingMessage: "Signing in, please wait a second",
                )
              : Container()),
        ],
      ),
    );
  }
}

class AuthDialog extends StatefulWidget {
  static const String routeName = "/AuthDialog";
  @override
  _AuthDialogState createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  late TextEditingController textControllerEmail;
  late TextEditingController textControllerPassword;
  late FocusNode textFocusNodeEmail;
  late FocusNode textFocusNodePassword;
  bool _isEditingEmail = false;

  @override
  void dispose() {
    super.dispose();
    textControllerEmail.dispose();
    textFocusNodeEmail.dispose();
    textFocusNodePassword.dispose();
    textControllerPassword.dispose();
  }

  @override
  void initState() {
    textControllerEmail = TextEditingController();
    textControllerPassword = TextEditingController();
    textControllerEmail.text = 'fusionage@gmail.com';
    textControllerPassword.text = '12345678';
    textFocusNodeEmail = FocusNode();
    textFocusNodePassword = FocusNode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: 300,
          height: 400,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    alignment: Alignment.center,
                    child: Text("version ${AppController.version}",
                        style: TextStyle(fontSize: 10))),
                Container(
                  height: 60,
                  padding: const EdgeInsets.all(10),
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text("Admin Sign In",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 30),
                TextField(
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.normal),
                  decoration: InputDecoration(
                    hintText: "Email",
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.white, width: 2.0),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10.0)),
                    ),
                    border: new OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.blueGrey.shade800,
                        width: 3,
                      ),
                    ),
                    errorText: _isEditingEmail
                        ? _validateEmail(textControllerEmail.text)
                        : null,
                    errorStyle:
                        TextStyle(fontSize: 12, color: Colors.redAccent),
                  ),
                  focusNode: textFocusNodeEmail,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  controller: textControllerEmail,
                  autofocus: false,
                  onChanged: (value) {
                    setState(() {
                      _isEditingEmail = true;
                    });
                  },
                  onSubmitted: (value) {
                    textFocusNodeEmail.unfocus();
                    FocusScope.of(context).requestFocus(textFocusNodePassword);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: textControllerPassword,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Password",
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.white, width: 2.0),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10.0)),
                    ),
                    border: new OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.blueGrey.shade800,
                        width: 3,
                      ),
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) {
                    execSignin();
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                      style: kButtonGold,
                      onPressed: execSignin,
                      child: Container(
                          alignment: Alignment.center,
                          width: 100,
                          child: Text("Sign in"))),
                ),
                Divider(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> execSignin() async {
    final ViewController ctrl = Get.find<ViewController>();

    ctrl.isBusy.value = true;

    Map<String, dynamic>? user =
        await FirebaseApi.checkUser(textControllerEmail.text);
    if (user == null) {
      ctrl.isBusy.value = false;
      Helper.msgBox(context, "Login Failed", "Invalid User email");
      return false;
    }

    EmailSigninResult result = await signInWithEmailPassword(
        textControllerEmail.text, textControllerPassword.text);
    ctrl.isBusy.value = false;
    //print(result.user);
    if (result.user != null) {
      AppController.signedInUser = user['name'];
      Get.offAll(PageHomeAdmin());
      return true;
    } else {
      Helper.msgBox(context, "Sign In Error", result.errorMessage ?? "");
    }

    return false;
  }

  String? _validateEmail(String value) {
    value = value.trim();

    if (textControllerEmail.text.isNotEmpty) {
      if (value.isEmpty) {
        return 'Email can\'t be empty';
      } else if (!value.contains(RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"))) {
        return 'Enter a correct email address';
      }
    }

    return null;
  }
}

Future<User?> signInWithGoogle() async {
  // Initialize Firebase
  User? user;

  // The `GoogleAuthProvider` can only be used while running on the web
  GoogleAuthProvider authProvider = GoogleAuthProvider();

  try {
    final UserCredential userCredential =
        await FirebaseApi.auth.signInWithPopup(authProvider);

    user = userCredential.user;
  } catch (ex) {
    print('Google Signin excaption:' + ex.toString());
  }

  return user;
}

// void signOutGoogle() async {
//   await googleSignIn.signOut();
//   await AppController.auth.signOut();

//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   prefs.setBool('auth', false);

//   AppController.uid = null;
//   name = null;
//   AppController.userEmail = null;
//   imageUrl = null;

//   print("User signed out of Google account");
// }

class EmailSigninResult {
  User? user;
  String? errorMessage;
}

Future<EmailSigninResult> signInWithEmailPassword(
    String email, String password) async {
  //await Firebase.initializeApp();
  EmailSigninResult result = EmailSigninResult();

  try {
    UserCredential userCredential =
        await FirebaseApi.auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    result.user = userCredential.user;
    result.errorMessage = "";

    //   if (result.user != null) {
    //     AppController.uid = result.user.uid;
    //     AppController.userEmail = result.user.email;
    //     AppController.photoURL = null;
    //     AppController.userName = result.user.email;
    //     AppController.isSignedIn=true;
    //     AppController.signinMethod='email';
    //     AppController.saveSetting();
    // }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      print('No user found for that email.');
      result.errorMessage = 'No user found for this email.';
    } else if (e.code == 'wrong-password') {
      print('Wrong password provided.');
      result.errorMessage = 'Wrong password provided';
    } else
      print('firebase signIn error code :' + e.code);
  }

  return result;
}
