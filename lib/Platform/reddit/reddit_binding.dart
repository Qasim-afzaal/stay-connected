import 'package:get/get.dart';

import 'package:stay_connected/Platform/reddit/reddit_controller.dart';

class RedditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RedditController>(
      () => RedditController(""),
    );
  }
} 