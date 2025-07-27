import 'package:get/get.dart';

import 'package:stay_connected/Platform/instagram/instagram_controller.dart';

class InstagramBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InstagramController>(
      () => InstagramController("Instagram"),
    );
  }
}
