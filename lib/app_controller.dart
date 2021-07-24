import 'package:collection/collection.dart';
import 'data_models.dart';
import 'firebase_api.dart';

class AppController {
  static const String version = "2.0";
  static const String fbDatabaseURL =
      "https://testbed-778e1-default-rtdb.asia-southeast1.firebasedatabase.app/";

  static List<MenuItem> menu = [];
  static String signedInUser = "";
  static String whatsAppNo = "60126897723";

  // static late FirebaseStorage firebaseStorage;
  // static late final FirebaseAuth firebaseAuth;
  // static late UserCredential? firebaseUser;
  // static late DatabaseReference firebaseDatabase_ref;
  // static FirebaseApp? _firebase_app;

  static AppController? _appController; //Singleton object
  AppController._createInstance();

  factory AppController() {
    if (_appController == null) {
      _appController = AppController._createInstance();
    }

    return _appController!;
  }

  static Future<String> initApp() async {
    try {
      //_firebase_app = await Firebase.initializeApp();
      FirebaseApi.init();

      //   firebaseStorage = firebase_storage.FirebaseStorage.instanceFor(bucket: 'gs://testbed-778e1.appspot.com');

      //   firebaseAuth = FirebaseAuth.instance;
      //   try {
      //     firebaseUser = await FirebaseAuth.instance.signInWithEmailAndPassword(
      //         email: 'ngyewchun@gmail.com',
      //         password:'eugene8668'
      //     );
      //   } on FirebaseAuthException catch (e) {
      //     if (e.code == 'user-not-found') {
      //       return ('Filebase Auth failed:No user found for that email.');
      //     } else if (e.code == 'wrong-password') {
      //       return ('Filebase Auth failed: Wrong password provided for that user.');
      //     }
      //   }

      //   final FirebaseDatabase database = FirebaseDatabase(app: _firebase_app,databaseURL: fbDatabaseURL);
      //   firebaseDatabase_ref = database.reference().child('feezyPayment');
      //   firebaseDatabase_ref.once().then((DataSnapshot snapshot) {
      //     print('Connected to feezyPayment database and read ${snapshot.value}');
      //  });

    } catch (ex) {
      print("AppController.InitApp exception :" + ex.toString());
    }
    return "";
  }

  static validateMenuItemCode(String itemCode, String id) {
    int idx = menu.indexWhere(
        (element) => (element.id != id && element.itemCode == itemCode));

    return (idx == -1);
  }

  static addMenuItem(String docid, Map<String, dynamic> jsonMap) {
    MenuItem? findItem = (menu.firstWhereOrNull(
        (element) => element.itemCode == jsonMap['itemCode']));
    if (findItem != null) menu.remove(findItem);
    jsonMap['id'] = docid;
    menu.add(MenuItem.fromJson(jsonMap));
  }

  // static Future<int> savePayment(Player player) async {

  //   try
  //   {
  //     DatabaseReference  id = await firebaseDatabase_ref.push();
  //     print("id=>${id.toString()}");
  //     id.set(player.toPaymentMap(id.key,userName));

  //   }
  //   catch(ex){
  //     print("exception ex:" + ex.toString());
  //   }
  //   return 11;
  // }

  // static Future<int> deletePayment(String payment_id) async {

  //   try
  //   {
  //     await firebaseDatabase_ref.child(payment_id).remove();
  //   }
  //   catch(ex){
  //     print("exception ex:" + ex.toString());
  //   }
  //   return 11;
  // }

  // static Future<firebase_storage.UploadTask> uploadFile(int userid, PickedFile file) async {

  //   firebase_storage.UploadTask uploadTask;

  //   String filename = file.path.split("/").last;

  //   // Create a Reference to the file
  //   firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
  //       .ref()
  //       .child('memberfee')
  //       .child(filename);

  //   final metadata = firebase_storage.SettableMetadata(
  //       contentType: 'image/jpeg',
  //       customMetadata: {'picked-file-path': file.path});

  //   uploadTask = ref.putData(await file.readAsBytes(), metadata);

  //   return Future.value(uploadTask);
  // }
}
