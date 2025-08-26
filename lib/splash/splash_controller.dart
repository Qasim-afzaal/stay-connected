import 'package:get/get.dart';

import 'package:stay_connected/routes/app_pages.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      Get.offNamed(Routes.HOME);
    });
    super.onReady();
  }
}
