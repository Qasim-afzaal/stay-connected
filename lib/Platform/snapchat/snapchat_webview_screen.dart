import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:stay_connected/Platform/snapchat/snapchat_controller.dart';

class SnapchatWebviewScreen extends StatefulWidget {
  final String searchQuery;
  final String iconName;
  final String platformName;

  const SnapchatWebviewScreen({
    super.key,
    required this.searchQuery,
    required this.iconName,
    required this.platformName,
  });

  @override
  State<SnapchatWebviewScreen> createState() => _SnapchatWebviewScreenState();
}

class _SnapchatWebviewScreenState extends State<SnapchatWebviewScreen> {
  late WebViewController _controller;
  String? currentUrl;
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;
  bool isBlocked = false;
  Timer? _loaderTimer;
  bool hasLoadedSuccessfully = false;

  @override
  void dispose() {
    _loaderTimer?.cancel();
    super.dispose();
  }

  void _startLoaderTimeout() {
    _loaderTimer?.cancel();
    print('Snapchat WebView - Starting 15 second timeout timer');
    _loaderTimer = Timer(const Duration(seconds: 15), () {
      print('Snapchat WebView - TIMEOUT: Loading took longer than 15 seconds');
      print('Snapchat WebView - Current URL: $currentUrl');
      print('Snapchat WebView - Is Loading: $isLoading');
      print('Snapchat WebView - Has Error: $hasError');
      if (mounted && isLoading && !hasLoadedSuccessfully) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage =
              'Loading timed out. Snapchat may be blocking this browser.';
        });
        print('Snapchat WebView - Set timeout error state');
      }
    });
  }

  Future<void> _checkBlockOrCaptcha() async {
    print('Snapchat WebView - Checking for block/captcha...');
    try {
      String? title = await _controller.getTitle();
      String url = currentUrl ?? '';
      print('Snapchat WebView - Page title: $title');
      print('Snapchat WebView - Current URL: $url');

      if ((title != null &&
              (title.toLowerCase().contains('not supported') ||
                  title.toLowerCase().contains('captcha') ||
                  title.toLowerCase().contains('challenge') ||
                  title.toLowerCase().contains('blocked'))) ||
          url.contains('challenge') ||
          url.contains('captcha') ||
          url.contains('blocked') ||
          url.contains('unsupported')) {
        print(
            'Snapchat WebView - BLOCK DETECTED: Title or URL contains block indicators');
        setState(() {
          isBlocked = true;
          isLoading = false;
          hasError = true;
          errorMessage =
              'Snapchat is blocking this browser or showing a captcha.';
        });
      } else {
        print('Snapchat WebView - No block detected, page appears normal');
      }
    } catch (e) {
      print('Snapchat WebView - Error checking block/captcha: $e');
    }
  }

  bool _isExpectedError(WebResourceError error) {
    return error.errorCode == -1002 ||
        error.errorCode == -999 ||
        error.errorCode == -1001;
  }

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    print('Snapchat WebView - Initializing WebView controller');

    String userAgent = Platform.isIOS
        ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1'
        : 'Mozilla/5.0 (Linux; Android 10; SM-G975F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(userAgent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('Snapchat WebView - Page Started: $url');
            print('Snapchat WebView - Starting loader timeout...');
            if (mounted) {
              setState(() {
                isLoading = true;
                hasError = false;
                errorMessage = null;
                isBlocked = false;
                currentUrl = url;
              });
              _startLoaderTimeout();
            }
          },
          onPageFinished: (String url) async {
            print('Snapchat WebView - Page Finished: $url');
            print('Snapchat WebView - Cancelling timeout timer');
            if (mounted) {
              setState(() {
                isLoading = false;
                currentUrl = url;
                hasLoadedSuccessfully = true;
              });
              await _checkBlockOrCaptcha();
              _loaderTimer?.cancel();
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            print('Snapchat WebView - Navigation Request: ${request.url}');
            if (mounted) {
              setState(() {
                currentUrl = request.url;
              });
            }
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            if (change.url != null && mounted) {
              print('Snapchat WebView - URL Changed: ${change.url}');
              setState(() {
                currentUrl = change.url!;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            print('Snapchat WebView - Error: ${error.description}');
            print('Snapchat WebView - Error Code: ${error.errorCode}');
            print('Snapchat WebView - Error URL: ${error.url}');

            if (!_isExpectedError(error) && !hasLoadedSuccessfully) {
              if (mounted) {
                setState(() {
                  isLoading = false;
                  hasError = true;
                  errorMessage = error.description;
                });
                _loaderTimer?.cancel();
              }
            } else if (_isExpectedError(error)) {
              print(
                  'Snapchat WebView - Ignoring expected error: ${error.errorCode}');
            }
          },
          onProgress: (int progress) {
            print('Snapchat WebView - Loading Progress: $progress%');
          },
        ),
      )
      ..setBackgroundColor(Colors.white)
      ..loadRequest(
        Uri.parse(
          'https://www.google.com/search?q=${Uri.encodeComponent(widget.searchQuery + " " + widget.platformName)}',
        ),
        headers: {
          'User-Agent': userAgent,
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.5',
          'Accept-Encoding': 'gzip, deflate, br',
          'DNT': '1',
          'Connection': 'keep-alive',
          'Upgrade-Insecure-Requests': '1',
          'Sec-Fetch-Dest': 'document',
          'Sec-Fetch-Mode': 'navigate',
          'Sec-Fetch-Site': 'none',
          'Cache-Control': 'max-age=0',
        },
      );

    Timer(const Duration(seconds: 5), () async {
      if (mounted && isLoading && !hasLoadedSuccessfully) {
        print(
            'Snapchat WebView - Fallback: Checking if page actually loaded after 5 seconds');
        try {
          String? title = await _controller.getTitle();
          print('Snapchat WebView - Fallback: Page title after 5s: $title');
          if (title != null && title.isNotEmpty) {
            print(
                'Snapchat WebView - Fallback: Page seems loaded, forcing finish');
            setState(() {
              isLoading = false;
              hasLoadedSuccessfully = true;
            });
            _loaderTimer?.cancel();
            await _checkBlockOrCaptcha();
          }
        } catch (e) {
          print('Snapchat WebView - Fallback: Error checking title: $e');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print(
        'Snapchat WebView - Build: isLoading=$isLoading, hasError=$hasError, hasLoadedSuccessfully=$hasLoadedSuccessfully');

    return Scaffold(
      appBar: AppBar(
        title: Text('Search: ${widget.searchQuery}'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showAddFriendDialog,
            icon: const Icon(Icons.person_add),
            tooltip: 'Add Friend',
          ),
        ],
      ),
      body: Stack(
        children: [
          if (hasError && !hasLoadedSuccessfully)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isBlocked ? Icons.block : Icons.error,
                    size: 50,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isBlocked
                        ? 'Snapchat is blocking this browser or showing a captcha.'
                        : 'Snapchat blocked the WebView',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey)),
                    ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        hasError = false;
                        isLoading = true;
                        isBlocked = false;
                        hasLoadedSuccessfully = false;
                      });
                      _controller.reload();
                      _startLoaderTimeout();
                    },
                    child: const Text("Retry"),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _showAddFriendDialog,
                    child: const Text('Add Friend Anyway'),
                  ),
                ],
              ),
            )
          else
            SizedBox.expand(
              child: WebViewWidget(controller: _controller),
            ),
          if (isLoading && !hasError)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.8),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        onPressed: _showAddFriendDialog,
        child: Image.asset(
          'assets/images/img_person_add_blue.png',
          width: 48,
          height: 48,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.person_add, size: 48);
          },
        ),
      ),
    );
  }

  void _showAddFriendDialog() async {
    final nameController = TextEditingController();
    final extractedName =
        _extractNameFromUrl(currentUrl ?? '') ?? widget.searchQuery;

    nameController.text = extractedName;

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CupertinoIcons.person_add,
                  color: CupertinoColors.systemBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Add Friend',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              children: [
                Text(
                  'Add this person to your ${widget.iconName} list?',
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 16),
                CupertinoTextField(
                  controller: nameController,
                  autofocus: true,
                  placeholder: 'Friend Name',
                  maxLength: 10,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Current URL: ${currentUrl ?? "Loading..."}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: CupertinoColors.systemGrey2,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            CupertinoDialogAction(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop();
                  _addFriendToIcon(nameController.text.trim(), currentUrl);
                }
              },
              isDefaultAction: true,
              child: const Text(
                'Add',
                style: TextStyle(
                  color: CupertinoColors.systemBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _addFriendToIcon(String friendName, String? profileUrl) {
    String finalProfileUrl = profileUrl ??
        'https://www.snapchat.com/add/${Uri.encodeComponent(friendName)}';

    final controller = Get.find<SnapchatController>();
    controller.addFriendToCategory(
        friendName, widget.iconName, finalProfileUrl);

    Get.back();

    Get.snackbar(
      'Friend Added Successfully!',
      '$friendName has been added to your ${widget.iconName} list',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green,
      colorText: Colors.white,
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
    );
  }

  String? _extractNameFromUrl(String url) {
    if (url.contains('snapchat.com/add/')) {
      String path = url.split('snapchat.com/add/')[1];
      if (path.isNotEmpty) {
        String username = path.split('?')[0].split('/')[0];
        return username.replaceAll('-', ' ').replaceAll('_', ' ');
      }
    }
    return null;
  }
}
