import 'package:get/get.dart';

import 'package:stay_connected/webview/webview_controller.dart';

class WebviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WebviewController>(
      () => WebviewController(""),
    );
  }
}
