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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: isDark ? theme.appBarTheme.backgroundColor : Colors.white,
        foregroundColor: isDark ? theme.appBarTheme.foregroundColor : Colors.black,
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(
            height: 1,
            thickness: 1,
            color: isDark ? Colors.grey[800] : Colors.grey[300],
          ),
        ),
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
