import 'package:get/get.dart';

import 'package:stay_connected/Platform/facebook/facebook_controller.dart';

class FacebookBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FaceBookController>(
      () => FaceBookController(""),
    );
  }
}
