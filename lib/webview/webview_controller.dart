import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewController extends GetxController {
  late final WebViewController webViewController;
  final String url;

  WebviewController(this.url);

  @override
  void onInit() {
    super.onInit();
    final uri = Uri.parse(url);
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(uri);
  }
}
