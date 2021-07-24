import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myorderweb/firebase_api.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_controller.dart';
import '../color_loader.dart';
import '../constants.dart';
import '../data_models.dart';
import '../helper.dart';
import 'signin.dart';

class PageOrder extends StatefulWidget {
  static String routeName = 'Order';
  final bool testView;

  PageOrder({Key? key, this.testView = false}) : super(key: key);

  @override
  _PageOrderState createState() => _PageOrderState();
}

class _PageOrderState extends State<PageOrder> {
  bool _initialized = false;
  bool _error = false;

  List<OrderItem> shoppingCart = [];
  DeliveryMethod? deliveryMethod = DeliveryMethod.Pickup;
  String deliveryAddress = "";
  final Stream<QuerySnapshot> _menuStream = FirebaseApi.readMenu();
  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }

  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
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
        appBar: AppBar(
          title: Center(
            child: Text("SendMyOrder\nKafe Fusion Age",
                style: TextStyle(fontSize: 13)),
          ),
          actions: [buildAppBarCartButton(context)],
          leading: widget.testView
              ? IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back))
              : IconButton(
                  onPressed: () {
                    Get.to(PageSignIn());
                  },
                  icon: Icon(Icons.login)),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                //width: 400,
                height: MediaQuery.of(context).size.height,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _menuStream,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("Loading menu");
                    }

                    String section = "";
                    return ListView(
                      children: [
                        ...buildMenuItems(
                            snapshot.data!.docs, section, context),
                        ElevatedButton(
                            style: kButtonGold,
                            onPressed: () => onCheckOutClicked(context),
                            child: Container(child: Text("Check Out"))),
                        const SizedBox(
                          height: 100,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  List<Column> buildMenuItems(
      List<QueryDocumentSnapshot> docs, String section, BuildContext context) {
    return docs.map((DocumentSnapshot document) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;

      AppController.addMenuItem(document.id, data);

      if (section != data['section']) {
        section = data['section'];
        return Column(
          children: [
            Text(
              section,
              style: Theme.of(context).textTheme.headline6,
            ),
            WgMenuItem(
              data: data,
              addToCart: onAddToCart,
            )
          ],
        );
      } else
        return Column(
          children: [
            WgMenuItem(
              data: data,
              addToCart: onAddToCart,
            ),
          ],
        );
    }).toList();
  }

  onAddToCart(Map<String, dynamic> json, int qty) {
    setState(() {
      int idx = shoppingCart
          .indexWhere((element) => element.item.itemCode == json['itemCode']);
      if (idx == -1) {
        shoppingCart.add(OrderItem(item: MenuItem.fromJson(json), qty: qty));

        Get.snackbar("order added to cart", "",
            snackPosition: SnackPosition.BOTTOM);
      } else {
        shoppingCart[idx].qty += qty;
        Get.snackbar("$qty added to exist order", "",
            snackPosition: SnackPosition.BOTTOM);
      }
    });
  }

  Widget buildAppBarCartButton(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: IconButton(
            onPressed: () => onCheckOutClicked(context),
            icon: Icon(Icons.shopping_cart_outlined, size: 30),
          ),
        ),
        Positioned(
          top: 0,
          right: 10,
          child: Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: Colors.white38),
              shape: BoxShape.circle,
            ),
            child: Text(shoppingCart.length.toString(),
                style: TextStyle(color: primaryColor)),
          ),
        )
      ],
    );
  }

  void onCheckOutClicked(BuildContext context) async {
    if (shoppingCart.isEmpty) {
      Get.snackbar("Cart is empty", "Please add some orders");
      return;
    }

    print("show Order Cart");

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return OrderCartDialog(
              deliveryAddress: deliveryAddress,
              deliveryMethod: this.deliveryMethod ?? DeliveryMethod.Pickup,
              title: "Your Order(${shoppingCart.length})",
              option: ["Share Order", "WhatsApp Order"],
              orderItems: shoppingCart,
              itemRemoved: () {
                setState(() {});
              },
              callBack: (ans, deliveryMethod, deliveryAddress) {
                String orderText = generateWhatsappOrderText();
                if (ans == "WhatsApp Order") {
                  //launch("https://api.whatsapp.com/send?phone=${AppController.whatsAppAgent}&text=UserID ${AppController.userID}\n");
                  this.deliveryMethod = deliveryMethod;
                  this.deliveryAddress = deliveryAddress;
                  launch(
                      "https://wa.me/send?${AppController.whatsAppNo}&text=${Uri.encodeFull(orderText)}\n");
                } else {
                  Share.share(orderText);
                }
              });
        });
  }

  String generateWhatsappOrderText() {
    double total = 0;
    String text = "My Order on " +
        DateTime.now().toIso8601String().substring(0, 10) +
        "\n" +
        shoppingCart
            .map((e) {
              double itemTotal = Helper.toMoney(e.item.price * e.qty);
              total += itemTotal;
              return "${e.item.itemCode} x ${e.qty} = $itemTotal";
            })
            .toList()
            .join("\n");
    text += "\nTotal Amount RM $total";
    text += (deliveryMethod == DeliveryMethod.Delivery)
        ? "\nDelivery Address:\n" + deliveryAddress
        : "\nSelf Pick-Up";
    return text;
  }
}

class WgMenuItem extends StatefulWidget {
  final Function(Map<String, dynamic>, int) addToCart;

  const WgMenuItem({
    Key? key,
    required this.data,
    required this.addToCart,
  }) : super(key: key);

  final Map<String, dynamic> data;

  @override
  _WgMenuItemState createState() => _WgMenuItemState();
}

class _WgMenuItemState extends State<WgMenuItem> {
  int qty = 1;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      constraints: BoxConstraints(minWidth: 420, maxWidth: 600),
      decoration: BoxDecoration(border: Border.all(color: Colors.white60)),
      child: Column(
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 3, child: buildItemDetails()),
            Expanded(
              flex: 2,
              child: ((widget.data['imageUrl'] ?? "") == "")
                  ? SizedBox.shrink()
                  : Image.network(
                      widget.data['imageUrl'],
                      fit: BoxFit.fill,
                    ),
            ),
          ]),
          buildAddToCart(),
        ],
      ),
    );
  }

  Container buildItemDetails() {
    return Container(
      constraints: BoxConstraints(maxHeight: 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.data['itemCode'] + " - RM ${widget.data['price']}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(widget.data['itemNameCn']),
          Text(widget.data['itemNameEn']),
        ],
      ),
    );
  }

  Container buildAddToCart() {
    return Container(
      padding: const EdgeInsets.only(right: 10),
      child: Row(
        children: [
          IconButton(
              onPressed: () {
                if (qty > 1) {
                  setState(() {
                    qty--;
                  });
                }
              },
              icon: Icon(Icons.do_disturb_on_outlined, size: 20)),
          Container(
            width: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade800),
            ),
            child: Text(qty.toString()),
          ),
          IconButton(
              onPressed: () {
                if (qty >= 30) return;
                setState(() {
                  qty++;
                });
              },
              icon: Icon(Icons.add_circle_outline, size: 20)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: darkColor, onPrimary: primaryColor),
            child: Text(
              "Add to cart",
              style: TextStyle(color: primaryColor, fontSize: 12),
            ),
            onPressed: () => widget.addToCart(widget.data, qty),
          ),
        ],
      ),
    );
  }
}

class OrderCartDialog extends StatefulWidget {
  final String title;
  final List<OrderItem> orderItems;
  final VoidCallback itemRemoved;
  final DeliveryMethod deliveryMethod;
  final String deliveryAddress;

  final List<String> option;
  final void Function(String, DeliveryMethod, String) callBack;

  OrderCartDialog(
      {required this.callBack,
      required this.option,
      required this.title,
      required this.orderItems,
      required this.itemRemoved,
      required this.deliveryMethod,
      required this.deliveryAddress});

  @override
  _OrderCartDialogState createState() => _OrderCartDialogState();
}

enum DeliveryMethod { Pickup, Delivery }

class _OrderCartDialogState extends State<OrderCartDialog> {
  double total = 0;
  DeliveryMethod deliveryMethod = DeliveryMethod.Pickup;
  TextEditingController ctrlAddress = TextEditingController();

  @override
  void initState() {
    super.initState();
    deliveryMethod = widget.deliveryMethod;
    ctrlAddress.text = widget.deliveryAddress;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    total = 0;
    const double addressHeight = 100;
    const double maxHeight = 600;
    double orderListHeight = 400;
    const double contentWidth = 500;
    final isKeyboard = MediaQuery.of(context).viewInsets.bottom != 0;
    print("isKeyboard:$isKeyboard");
    if (isKeyboard) orderListHeight = 100;
    return Stack(
      fit: StackFit.expand,
      children: [
        SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
                minWidth: contentWidth,
                maxHeight: maxHeight +
                    (deliveryMethod == DeliveryMethod.Pickup
                        ? 0
                        : addressHeight)),
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 16),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(Consts.padding),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.title,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )),
                Container(
                  constraints: BoxConstraints(maxHeight: orderListHeight),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min, // To make the card compact
                      children: buildCartItem(contentWidth),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Text("Total RM ${Helper.toMoney(total)}",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ],
                ),
                buildDeliveryMethod(contentWidth, orderListHeight),
                (deliveryMethod == DeliveryMethod.Pickup)
                    ? const SizedBox.shrink()
                    : buildDeliveryAddressField(),
                buildButtonRow(contentWidth, context),
              ],
            ),
          ),
        ),
        Positioned(
          right: 0,
          child: IconButton(
              padding: const EdgeInsets.all(0),
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.highlight_remove,
                color: primaryColor,
                size: 36,
              )),
        ),
      ],
    );
  }

  Widget buildDeliveryMethod(double contentWidth, double contentHeight) {
    return Container(
      constraints:
          BoxConstraints(maxWidth: contentWidth, maxHeight: contentHeight),
      height: 35,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildPickUpButton(),
          buildDeliveryButton(),
        ],
      ),
    );
  }

  InkWell buildPickUpButton() {
    return InkWell(
      onTap: () {
        setState(() {
          deliveryMethod = DeliveryMethod.Pickup;
        });
      },
      child: Row(
        children: [
          Text("Pick-Up"),
          Radio<DeliveryMethod>(
              activeColor: primaryColor,
              value: DeliveryMethod.Pickup,
              groupValue: deliveryMethod,
              onChanged: (DeliveryMethod? value) {
                setState(() {
                  deliveryMethod = value ?? DeliveryMethod.Pickup;
                });
              }),
        ],
      ),
    );
  }

  InkWell buildDeliveryButton() {
    return InkWell(
      onTap: () {
        setState(() {
          deliveryMethod = DeliveryMethod.Delivery;
        });
      },
      child: Row(
        children: [
          Text("Delivery"),
          Radio(
              activeColor: primaryColor,
              value: DeliveryMethod.Delivery,
              groupValue: deliveryMethod,
              onChanged: (DeliveryMethod? value) {
                print("pickup click $value");
                setState(() {
                  deliveryMethod = value ?? DeliveryMethod.Delivery;
                });
              }),
        ],
      ),
    );
  }

  Container buildButtonRow(double contentWidth, BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      constraints: BoxConstraints(maxWidth: contentWidth),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints.tightFor(width: 100, height: 30),
            child: ElevatedButton(
              style: kButtonGold.copyWith(textStyle:
                  MaterialStateProperty.resolveWith<TextStyle>(
                      (Set<MaterialState> states) {
                return TextStyle(fontSize: 12);
              })),
              onPressed: () {
                Navigator.of(context).pop(); // To close the dialog
                widget.callBack(
                    widget.option[0], deliveryMethod, ctrlAddress.text);
              },
              child: Text(widget.option[0],
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: BoxConstraints.tightFor(width: 100, height: 30),
            child: ElevatedButton(
              //Send Order button
              style: kButtonGold.copyWith(textStyle:
                  MaterialStateProperty.resolveWith<TextStyle>(
                      (Set<MaterialState> states) {
                return TextStyle(fontSize: 12);
              })),
              onPressed: () {
                if (deliveryMethod == DeliveryMethod.Delivery &&
                    ctrlAddress.text.trim().isEmpty) {
                  Helper.msgBox(context, "Error! Empty Delivery Address",
                      "You have selected Deliver method, please enter Delivery Address");
                  return;
                }
                Navigator.of(context).pop(); // To close the dialog
                widget.callBack(
                    widget.option[1], deliveryMethod, ctrlAddress.text);
              },
              child: Text(widget.option[1],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Container buildDeliveryAddressField() {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      height: 100,
      child: TextField(
        maxLines: 5,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
        controller: ctrlAddress,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 2.0),
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          ),
          hintText: "Please enter your delivery address",
          labelText: "Delivery Address",
          labelStyle: TextStyle(color: Colors.white),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 2.0),
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          ),
        ),
      ),
    );
  }

  Container buildTotal(
      double contentWidth, double contentHeight, BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxWidth: contentWidth, maxHeight: contentHeight),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text("Total RM ${Helper.toMoney(total)}",
              style: Theme.of(context).textTheme.subtitle1),
        ],
      ),
    );
  }

  List<Widget> buildCartItem(double contentWidth) {
    int idx = 0;
    return widget.orderItems.map((orderItem) {
      idx++;
      total += orderItem.item.price * orderItem.qty;
      return Stack(
        children: [
          Container(
            width: contentWidth,
            //height: 90,
            margin: const EdgeInsets.only(top: 20, right: 20, left: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade800),
            ),
            child: ListTile(
              title: Row(
                children: [
                  Text(
                    "$idx) ${orderItem.item.itemCode}  x ${orderItem.qty}",
                    style: TextStyle(color: Colors.white),
                  ),
                  IconButton(
                    padding: const EdgeInsets.only(left: 2.0),
                    icon: Icon(Icons.remove_outlined,
                        size: 15, color: primaryColor),
                    onPressed: () {
                      if (orderItem.qty == 1) return;
                      setState(() {
                        orderItem.qty--;
                        if (orderItem.qty == 0) {
                          widget.orderItems.remove(orderItem);
                          widget.itemRemoved();
                        }
                      });
                    },
                  ),
                  IconButton(
                    padding: const EdgeInsets.only(left: 2.0),
                    icon: Icon(Icons.add, size: 15, color: primaryColor),
                    onPressed: () {
                      setState(() {
                        orderItem.qty++;
                      });
                    },
                  ),
                ],
              ),
              subtitle: Container(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${orderItem.item.itemNameCn}",
                        style: TextStyle(color: Colors.white)),
                    Text("${orderItem.item.itemNameEn}",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              trailing: Text(
                  "${Helper.toMoney(orderItem.qty * orderItem.item.price)}",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),
          Positioned(
            right: 0,
            child: IconButton(
                onPressed: () {
                  setState(() {
                    widget.orderItems.removeAt(idx - 1);
                    widget.itemRemoved();
                    if (widget.orderItems.isEmpty) Navigator.pop(context);
                  });
                },
                icon: Icon(
                  Icons.highlight_remove,
                  color: primaryColor,
                )),
          ),
        ],
      );
    }).toList();
  }
}
