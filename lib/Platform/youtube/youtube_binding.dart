import 'package:get/get.dart';

import 'package:stay_connected/Platform/youtube/youtube_controller.dart';

class YouTubeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<YouTubeController>(
      () => YouTubeController(""),
    );
  }
} 