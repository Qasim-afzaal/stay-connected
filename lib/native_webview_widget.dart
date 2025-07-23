import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class NativeWebViewWidget extends StatefulWidget {
  final String initialUrl;
  final Function(String)? onPageStarted;
  final Function(String)? onPageFinished;
  final Function(String)? onError;

  const NativeWebViewWidget({
    Key? key,
    required this.initialUrl,
    this.onPageStarted,
    this.onPageFinished,
    this.onError,
  }) : super(key: key);

  @override
  State<NativeWebViewWidget> createState() => _NativeWebViewWidgetState();
}

class _NativeWebViewWidgetState extends State<NativeWebViewWidget> {
  static const MethodChannel _channel = MethodChannel('webview_plugin');
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;
  String? currentUrl;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    try {
      await _channel.invokeMethod('createWebView', {'url': widget.initialUrl});
      print('Native WebView - Initialized with URL: ${widget.initialUrl}');
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Native WebView - Error initializing: $e');
      setState(() {
        hasError = true;
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> loadUrl(String url) async {
    try {
      await _channel.invokeMethod('loadUrl', {'url': url});
    } catch (e) {
      print('Error loading URL: $e');
    }
  }

  Future<void> reload() async {
    try {
      await _channel.invokeMethod('reload');
    } catch (e) {
      print('Error reloading: $e');
    }
  }

  Future<String?> getTitle() async {
    try {
      return await _channel.invokeMethod('getTitle');
    } catch (e) {
      print('Error getting title: $e');
      return null;
    }
  }

  Future<String?> getCurrentUrl() async {
    try {
      return await _channel.invokeMethod('getCurrentUrl');
    } catch (e) {
      print('Error getting current URL: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only show native WebView on iOS
    if (Platform.isIOS) {
      return _buildNativeWebView();
    } else {
      // Fallback for Android
      return _buildFallbackWebView();
    }
  }

  Widget _buildNativeWebView() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.web, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'Native WebView (iOS)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'URL: ${currentUrl ?? widget.initialUrl}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            if (hasError) ...[
              const SizedBox(height: 16),
              Text(
                'Error: $errorMessage',
                style: const TextStyle(fontSize: 12, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: reload,
                  child: const Text('Reload'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final title = await getTitle();
                    print('Page title: $title');
                  },
                  child: const Text('Get Title'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackWebView() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.web, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'Native WebView (iOS Only)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'This feature is only available on iOS',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
