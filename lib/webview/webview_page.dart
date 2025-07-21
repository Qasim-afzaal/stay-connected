import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:stay_connected/webview/webview_controller.dart';

class WebviewPage extends StatelessWidget {
  const WebviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final title = Get.arguments['title'] ?? 'Web';
    final url = Get.arguments['url'];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: GetBuilder<WebviewController>(
        init: WebviewController(url),
        builder: (controller) {
          return WebViewWidget(controller: controller.webViewController);
        },
      ),
    );
  }
}
