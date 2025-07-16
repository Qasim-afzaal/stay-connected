import 'package:get/get.dart';

import 'package:stay_connected/Platform/twitter/twitter_controller.dart';

class TwitterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TwitterController>(
      () => TwitterController(""),
    );
  }
} 