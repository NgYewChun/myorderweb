import 'package:flutter/material.dart';

const primaryColor = Color(0xFFFFC107);
const secondaryColor = Color(0xFF242430);
const darkColor = Color(0xFF191923);
const bodyTextColor = Color(0xFF8B8B8D);
const bgColor = Color(0xFF1E1E28);

final kStyleLabel = TextStyle(
  fontSize: 20.0,
  fontWeight: FontWeight.w600,
);

final kStyleButton = TextStyle(
  fontWeight: FontWeight.w600,
);

final double kButtonHeight = 35;
final TextStyle kButtonTextStyle =
    TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500);

final ButtonStyle kButtonStyle = ElevatedButton.styleFrom(
  elevation: 10,
  textStyle: kButtonTextStyle,
  primary: Colors.white,
  onPrimary: Colors.red,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8.0),
    side: BorderSide(
      width: 1,
      color: Colors.red,
    ),
  ),
);

final ButtonStyle kButtonHelper = ElevatedButton.styleFrom(
  primary: Colors.white,
  onPrimary: Colors.green,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(30.0),
    side: BorderSide(
      width: 1,
      color: Colors.green,
    ),
  ),
  padding: const EdgeInsets.symmetric(horizontal: 15),
  alignment: Alignment.center,
);
final ButtonStyle kButtonGold = ElevatedButton.styleFrom(
  primary: darkColor,
  onPrimary: primaryColor,
  shape: RoundedRectangleBorder(
    borderRadius: new BorderRadius.circular(30.0),
    side: BorderSide(
      width: 1,
      color: primaryColor,
    ),
  ),
);

final double kMaxWidth = 600;

class Consts {
  Consts._();

  static MaterialColor mcPrimaryColor = createMaterialColor(primaryColor);

  static const double padding = 16.0;
  static const double avatarRadius = 50.0;
  static final dlgPadding = EdgeInsets.only(
    top: Consts.avatarRadius + Consts.padding,
    bottom: Consts.padding,
    left: Consts.padding,
    right: Consts.padding,
  );

  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    return MaterialColor(color.value, swatch);
  }

  static final dlgBoxDecoration = BoxDecoration(
    color: Colors.white,
    shape: BoxShape.rectangle,
    borderRadius: BorderRadius.circular(Consts.padding),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 10.0,
        offset: const Offset(0.0, 10.0),
      ),
    ],
  );
}

class TxnStatus {
  static final int raw = 0;
  static final int pendingConfirm = 3;
  static final int pendingMPesaRequest = 4;
  static final int pendingMPesaApproval = 5;
  static final int complete = 10;
  static final int cancelled = 11;
  static final int invalidated = 12;
}

class ApiResultCode {
  static final int success = 1;
  static final int unclosedTxn = 2;
  static final int exceptionError = -1;
  static final int connectionError = -2;
}
