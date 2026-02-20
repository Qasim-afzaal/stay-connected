import 'package:get/get.dart';

import 'package:stay_connected/routes/app_pages.dart';

class SplashController extends GetxController {
  static const _splashDelay = Duration(milliseconds: 1500);

  @override
  void onReady() {
    Future.delayed(_splashDelay, () {
      Get.offNamed(Routes.HOME);
    });
    super.onReady();
  }
}
