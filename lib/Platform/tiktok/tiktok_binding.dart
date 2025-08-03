import 'package:get/get.dart';

import 'package:stay_connected/Platform/tiktok/tiktok_controller.dart';

class TikTokBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TikTokController>(
      () => TikTokController("TikTok"),
    );
  }
}
