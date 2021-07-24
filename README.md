# myorderweb

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

D:\Dropbox\programming\FlutterWeb>flutter create myorderweb

https://firebase.flutter.dev/docs/overview#initializing-flutterfire
https://firebase.flutter.dev/docs/storage/overview

setup firebase database
login to firebase console, create project, app, goto cloud firestore -> create database
tutorial https://www.youtube.com/watch?v=Z0jFkP0A3B0

add following script to index.html

<script src="https://www.gstatic.com/firebasejs/8.6.1/firebase-app.js"></script>
<script src="https://www.gstatic.com/firebasejs/8.6.1/firebase-firestore.js"></script>
<!-- TODO: Add SDKs for Firebase products that you want to use
     https://firebase.google.com/docs/web/setup#available-libraries -->

<script>
  // Your web app's Firebase configuration
  var firebaseConfig = {
    apiKey: "AIzaSyDbvVqLZOIZaMnajOJvzMzSlfL2DcCxBQc",
    authDomain: "myorder-faea6.firebaseapp.com",
    projectId: "myorder-faea6",
    storageBucket: "myorder-faea6.appspot.com",
    messagingSenderId: "768180177930",
    appId: "1:768180177930:web:eb553be92f7510b7b6e3f3"
  };
  // Initialize Firebase
  firebase.initializeApp(firebaseConfig);
</script>

add <script src="https://www.gstatic.com/firebasejs//8.6.1/firebase-storage.js"></script> for firestorage

add pubspec.ymal
firebase_core: "^1.3.0"
cloud_firestore: ^2.3.0

Initializing FlutterFire
https://firebase.flutter.dev/docs/overview#initializing-flutterfire
import 'package:flutter/material.dart';

// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';

void main() {
WidgetsFlutterBinding.ensureInitialized();
runApp(App());
}

class App extends StatefulWidget {
\_AppState createState() => \_AppState();
}

class \_AppState extends State<App> {
// Set default `_initialized` and `_error` state to false
bool \_initialized = false;
bool \_error = false;

// Define an async function to initialize FlutterFire
void initializeFlutterFire() async {
try {
// Wait for Firebase to initialize and set `_initialized` state to true
await Firebase.initializeApp();
setState(() {
\_initialized = true;
});
} catch(e) {
// Set `_error` state to true if Firebase initialization fails
setState(() {
\_error = true;
});
}
}

@override
void initState() {
initializeFlutterFire();
super.initState();
}

@override
Widget build(BuildContext context) {
// Show error message if initialization failed
if(\_error) {
return SomethingWentWrong();
}

    // Show a loader until FlutterFire is initialized
    if (!_initialized) {
      return Loading();
    }

    return MyAwesomeApp();

}
}

firestore CRUD
https://firebase.flutter.dev/docs/firestore/usage

####deploy to firebase hosting:.
https://www.youtube.com/watch?v=xJo7Mqse960
https://medium.com/flutter/must-try-use-firebase-to-host-your-flutter-app-on-the-web-852ee533a469
https://firebase.google.com/docs/hosting/

D:\Dropbox\programming\FlutterWeb\myorderweb>npm install -g firebase-tools ##install one time only

D:\Dropbox\programming\FlutterWeb\myorderweb>firebase login

Waiting for authentication...

- Success! Logged in as ngyewchun@gmail.com

D:\Dropbox\programming\FlutterWeb\myorderweb>npm install -g firebase-tools

D:\Dropbox\programming\FlutterWeb\myorderweb>firebase login
Already logged in as ngyewchun@gmail.com

D:\Dropbox\programming\FlutterWeb\myorderweb>firebase init

     ######## #### ########  ######## ########     ###     ######  ########
     ##        ##  ##     ## ##       ##     ##  ##   ##  ##       ##
     ######    ##  ########  ######   ########  #########  ######  ######
     ##        ##  ##    ##  ##       ##     ## ##     ##       ## ##
     ##       #### ##     ## ######## ########  ##     ##  ######  ########

You're about to initialize a Firebase project in this directory:

D:\Dropbox\programming\FlutterWeb\myorderweb

? Are you ready to proceed? Yes
? What do you want to use as your public directory? build/web
? Configure as a single-page app (rewrite all urls to /index.html)? Yes
? Set up automatic builds and deploys with GitHub? No

- Wrote build/web/index.html

i Writing configuration info to firebase.json...
i Writing project information to .firebaserc...

- Firebase initialization complete!

D:\Dropbox\programming\FlutterWeb\myorderweb>flutter build web --web-renderer html

D:\Dropbox\programming\FlutterWeb\myorderweb>firebase deploy --only hosting

=== Deploying to 'myorder-faea6'...

i deploying hosting
i hosting[myorder-faea6]: beginning deploy...
i hosting[myorder-faea6]: found 18 files in build/web

- hosting[myorder-faea6]: file upload complete
  i hosting[myorder-faea6]: finalizing version...
- hosting[myorder-faea6]: version finalized
  i hosting[myorder-faea6]: releasing new version...
- hosting[myorder-faea6]: release complete

- Deploy complete!

Project Console: https://console.firebase.google.com/project/myorder-faea6/overview
Hosting URL: https://myorder-faea6.web.app

D:\Dropbox\programming\FlutterWeb\myorderweb>
