import 'package:get/get.dart';

import 'package:stay_connected/Platform/snapchat/snapchat_controller.dart';

class SnapchatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SnapchatController>(
      () => SnapchatController("Snapchat"),
    );
  }
}
