import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myorderweb/screens/add_menu_item.dart';
import 'package:myorderweb/screens/home.dart';
import 'app_controller.dart';
import 'constants.dart';
import 'screens/edit_menu.dart';
import 'screens/home_admin.dart';
import 'screens/order_page.dart';
import 'screens/signin.dart';
import 'screens/view_controller.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initApp();
  runApp(MyApp());
}

void initApp() async {
  //await Firebase.initializeApp();
  AppController.initApp();
  Get.put(ViewController());
  print('All services started...');

  //final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  //WebBrowserInfo data = await deviceInfoPlugin.webBrowserInfo;

  // print('browserName ${describeEnum(data.browserName)}\n' +
  //     'appCodeName  ${data.appCodeName}\n' +
  //     'appName ${data.appName}\n' +
  //     'appVersion ${data.appVersion}\n' +
  //     'deviceMemory ${data.deviceMemory}\n' +
  //     'language ${data.language}\n' +
  //     'languages ${data.languages}\n' +
  //     'platform ${data.platform}\n' +
  //     'product ${data.product}\n' +
  //     'productSub ${data.productSub}\n' +
  //     'userAgent ${data.userAgent}\n' +
  //     'vendor ${data.vendor}\n' +
  //     'vendorSub ${data.vendorSub}}\n' +
  //     'hardwareConcurrency ${data.hardwareConcurrency}\n' +
  //     'maxTouchPoints ${data.maxTouchPoints}');
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyOrderWeb',
      theme: ThemeData.dark().copyWith(
        primaryColor: secondaryColor,
        scaffoldBackgroundColor: bgColor,
        canvasColor: bgColor,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Consts.mcPrimaryColor,
        ).copyWith(),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: Colors.white)
            .copyWith(
              bodyText1: TextStyle(color: bodyTextColor),
              bodyText2: TextStyle(color: bodyTextColor),
            ),
      ),
      initialRoute: PageOrder.routeName,
      getPages: [
        GetPage(name: PageEditMenu.routeName, page: () => PageEditMenu()),
        GetPage(name: PageAddMenuItem.routeName, page: () => PageAddMenuItem()),
        GetPage(name: PageOrder.routeName, page: () => PageOrder()),
        GetPage(name: PageHomeAdmin.routeName, page: () => PageHomeAdmin()),
        GetPage(name: PageHome.routeName, page: () => PageHome()),
        GetPage(name: PageSignIn.routeName, page: () => PageSignIn()),
      ], // MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
