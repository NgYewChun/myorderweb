import 'helper.dart';

class User {
  late String id;
  late String email;
  late String name;

  User({required this.id, required this.email, required this.name});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
      };

  static User fromJson(Map<String, dynamic> json) {
    return User(id: json['id'] ?? "", email: json['email'], name: json['name']);
  }
}

class MyBanner {
  late String id;
  DateTime? dtCreated;
  String? title;
  String? imageUrl;
  int sortOrder;
  MyBanner(
      {required this.id,
      required this.title,
      required this.dtCreated,
      required this.sortOrder,
      required this.imageUrl});

  Map<String, dynamic> toJson() => {
        'title': title,
        'id': id,
        'imageUrl': imageUrl,
        'sortOrder': sortOrder,
        'dtCreated': Helper.fromDateTimeToJson(dtCreated)
      };

  static MyBanner fromJson(Map<String, dynamic> json) {
    return MyBanner(
        id: json['id'] ?? "",
        title: json['title'],
        imageUrl: json['imageUrl'],
        sortOrder: json['sortOrder'],
        dtCreated: Helper.toDateTime(json['dtCreated']));
  }
}

class OrderItem {
  late MenuItem item;
  late int qty;

  OrderItem({required this.item, required this.qty});
}

class MenuItem {
  String id;
  late DateTime dtCreated;
  late String section;
  late String itemCode;
  late String itemNameCn;
  late String itemNameEn;
  late String itemNameMy;
  late double price;
  late bool isChefRecommended;
  late bool isSpicy;
  late String imageUrl;
  late int sortOrder;

  MenuItem(
      {required this.id,
      required this.section,
      required this.itemCode,
      required this.itemNameCn,
      required this.itemNameEn,
      required this.itemNameMy,
      required this.price,
      required this.isChefRecommended,
      required this.isSpicy,
      required this.imageUrl,
      required this.dtCreated,
      this.sortOrder = 0});

  Map<String, dynamic> toJson() => {
        'id': id,
        'section': section,
        'itemCode': itemCode,
        'itemNameCn': itemNameCn,
        'itemNameEn': itemNameEn,
        'itemNameMy': itemNameMy,
        'price': price,
        'isChefRecommended': isChefRecommended,
        'isSpicy': isSpicy,
        'imageUrl': imageUrl,
        'dtCreated': Helper.fromDateTimeToJson(dtCreated),
        'sortOrder': sortOrder
      };

  static MenuItem fromJson(Map<String, dynamic> json) {
    return MenuItem(
        id: json['id'] ?? "",
        section: json['section'],
        itemCode: json['itemCode'],
        itemNameCn: json['itemNameCn'],
        itemNameEn: json['itemNameEn'],
        itemNameMy: json['itemNameMy'],
        price: double.parse(json['price'].toString()),
        isChefRecommended: json['isChefRecommended'] ?? false,
        isSpicy: json['isSpicy'] ?? false,
        imageUrl: json['imageUrl'] ?? "",
        sortOrder: json['sortOrder'] ?? 0,
        dtCreated: Helper.toDateTime(json['dtCreated']));
  }
}
