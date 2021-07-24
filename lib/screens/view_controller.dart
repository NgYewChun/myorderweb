import 'package:get/get.dart';

class ViewBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ViewController());
  }
}

class ViewController extends GetxController {
  var isBusy = false.obs;

  @override
  void onInit() {
    super.onInit();

    //  kplcPrepaidRequest = KPLCPrepaidRequest(
    //    amount: 10,
    //    charge: 5.0,
    //    iStatus:5,
    //    meter: '14244403557',
    //    meterName: 'SHABBIR HASSAN RAHMAN',
    //    phone: '0720383030',
    //    reqTime:'2021-06-14 16:14:14',
    //    product: 'KPLC Prepaid',
    //    requestIdx: 11513);
  }

  @override
  void onClose() {
    super.onClose();
  }
}
