import 'package:get/get.dart';

import 'package:stay_connected/Platform/pinterest/pinterest_controller.dart';

class PinterestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PinterestController>(
      () => PinterestController(""),
    );
  }
} 