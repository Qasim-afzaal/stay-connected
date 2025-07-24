import 'package:flutter/material.dart';
import 'package:stay_connected/native_webview_widget.dart';

class TestNativeWebView extends StatefulWidget {
  const TestNativeWebView({Key? key}) : super(key: key);

  @override
  State<TestNativeWebView> createState() => _TestNativeWebViewState();
}

class _TestNativeWebViewState extends State<TestNativeWebView> {
  String? currentUrl;
  String? pageTitle;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Native WebView Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Status info
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current URL: ${currentUrl ?? "Loading..."}'),
                const SizedBox(height: 8),
                Text('Page Title: ${pageTitle ?? "Loading..."}'),
                const SizedBox(height: 8),
                Text('Loading: $isLoading'),
              ],
            ),
          ),

          // Native WebView
          Expanded(
            child: NativeWebViewWidget(
              initialUrl: 'https://www.google.com',
              onPageStarted: (url) {
                print('Test - Page Started: $url');
                setState(() {
                  currentUrl = url;
                  isLoading = true;
                });
              },
              onPageFinished: (url) async {
                print('Test - Page Finished: $url');
                setState(() {
                  currentUrl = url;
                  isLoading = false;
                });

                // Get page title
                // Note: This would require accessing the method channel from the widget
                // For now, we'll just show the URL as title
                setState(() {
                  pageTitle = url;
                });
              },
              onError: (error) {
                print('Test - Error: $error');
                setState(() {
                  isLoading = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
