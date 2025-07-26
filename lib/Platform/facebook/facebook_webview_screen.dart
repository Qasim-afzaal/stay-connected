import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'dart:io';

import 'package:stay_connected/Platform/facebook/facebook_controller.dart';

class FacebookWebviewScreen extends StatefulWidget {
  final String searchQuery;
  final String iconName;
  final String platformName;

  const FacebookWebviewScreen({
    Key? key,
    required this.searchQuery,
    required this.iconName,
    required this.platformName,
  }) : super(key: key);

  @override
  State<FacebookWebviewScreen> createState() => _FacebookWebviewScreenState();
}

class _FacebookWebviewScreenState extends State<FacebookWebviewScreen> {
  late WebViewController _controller;
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;
  bool isBlocked = false;
  Timer? _loaderTimer;
  Timer? _fallbackTimer;
  Timer? _progressTimer;
  bool hasLoadedSuccessfully = false;
  String? currentUrl;
  int loadingProgress = 0;
  int lastProgressUpdate = 0;
  bool isNavigatingToApp = false;

  @override
  void dispose() {
    _loaderTimer?.cancel();
    _fallbackTimer?.cancel();
    _progressTimer?.cancel();
    super.dispose();
  }

  void _startLoaderTimeout() {
    _loaderTimer?.cancel();
    print('Facebook WebView - Starting 25 second timeout timer');
    _loaderTimer = Timer(const Duration(seconds: 25), () {
      print('Facebook WebView - TIMEOUT: Loading took longer than 25 seconds');
      print('Facebook WebView - Current URL: $currentUrl');
      print('Facebook WebView - Is Loading: $isLoading');
      print('Facebook WebView - Has Error: $hasError');
      print('Facebook WebView - Loading Progress: $loadingProgress%');
      if (mounted &&
          isLoading &&
          !hasLoadedSuccessfully &&
          !isNavigatingToApp) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage =
              'Loading timed out. Facebook may be blocking this browser.';
        });
        print('Facebook WebView - Set timeout error state');
      }
    });
  }

  void _startProgressStuckTimer() {
    _progressTimer?.cancel();
    _progressTimer = Timer(const Duration(seconds: 3), () {
      if (mounted &&
          isLoading &&
          !hasLoadedSuccessfully &&
          loadingProgress >= 85 &&
          !isNavigatingToApp) {
        print(
            'Facebook WebView - Progress stuck at $loadingProgress%, forcing completion');
        setState(() {
          isLoading = false;
          hasLoadedSuccessfully = true;
        });
        _loaderTimer?.cancel();
        _fallbackTimer?.cancel();
        _progressTimer?.cancel();
      }
    });
  }

  Future<void> _checkBlockOrCaptcha() async {
    print('Facebook WebView - Checking for block/captcha...');
    try {
      String? title = await _controller.getTitle();
      String url = currentUrl ?? '';
      print('Facebook WebView - Page title: $title');
      print('Facebook WebView - Current URL: $url');

      if ((title != null &&
              (title.toLowerCase().contains('not supported') ||
                  title.toLowerCase().contains('captcha') ||
                  title.toLowerCase().contains('challenge') ||
                  title.toLowerCase().contains('blocked') ||
                  title.toLowerCase().contains('checkpoint'))) ||
          url.contains('challenge') ||
          url.contains('captcha') ||
          url.contains('blocked') ||
          url.contains('unsupported') ||
          url.contains('checkpoint')) {
        print(
            'Facebook WebView - BLOCK DETECTED: Title or URL contains block indicators');
        setState(() {
          isBlocked = true;
          isLoading = false;
          hasError = true;
          errorMessage =
              'Facebook is blocking this browser or showing a captcha.';
        });
      } else {
        print('Facebook WebView - No block detected, page appears normal');
      }
    } catch (e) {
      print('Facebook WebView - Error checking block/captcha: $e');
    }
  }

  bool _isExpectedError(WebResourceError error) {
    // These are expected errors that don't indicate a real problem
    return error.errorCode == -1002 || // unsupported URL (fb:// protocol)
        error.errorCode == -999 || // cancelled navigation
        error.errorCode ==
            -1001; // timed out (sometimes happens during redirects)
  }

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    print('Facebook WebView - Initializing WebView controller');

    // Platform-specific user agent for better compatibility
    String userAgent = Platform.isIOS
        ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1'
        : 'Mozilla/5.0 (Linux; Android 10; SM-G975F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(userAgent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('Facebook WebView - Page Started: $url');

            // Check if this is a Facebook app redirect
            if (url.startsWith('fb://')) {
              print(
                  'Facebook WebView - Detected Facebook app redirect, ignoring');
              setState(() {
                isNavigatingToApp = true;
              });
              return;
            }

            print('Facebook WebView - Starting loader timeout...');
            if (mounted) {
              setState(() {
                isLoading = true;
                hasError = false;
                errorMessage = null;
                isBlocked = false;
                currentUrl = url;
                loadingProgress = 0;
                lastProgressUpdate = 0;
                isNavigatingToApp = false;
              });
              _startLoaderTimeout();
            }
          },
          onPageFinished: (String url) async {
            print('Facebook WebView - Page Finished: $url');

            // Don't process app redirects
            if (url.startsWith('fb://')) {
              print('Facebook WebView - Ignoring app redirect completion');
              return;
            }

            print('Facebook WebView - Cancelling timeout timer');
            if (mounted) {
              setState(() {
                isLoading = false;
                currentUrl = url;
                hasLoadedSuccessfully = true;
                loadingProgress = 100;
                isNavigatingToApp = false;
              });
              await _checkBlockOrCaptcha();
              _loaderTimer?.cancel();
              _fallbackTimer?.cancel();
              _progressTimer?.cancel();
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            print('Facebook WebView - Navigation Request: ${request.url}');

            // Handle Facebook app redirects
            if (request.url.startsWith('fb://')) {
              print('Facebook WebView - Blocking Facebook app redirect');
              setState(() {
                isNavigatingToApp = true;
              });
              return NavigationDecision.prevent;
            }

            if (mounted) {
              setState(() {
                currentUrl = request.url;
                isNavigatingToApp = false;
              });
            }
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            if (change.url != null && mounted) {
              print('Facebook WebView - URL Changed: ${change.url}');

              // Handle Facebook app redirects
              if (change.url!.startsWith('fb://')) {
                print('Facebook WebView - Detected app redirect URL change');
                setState(() {
                  isNavigatingToApp = true;
                });
                return;
              }

              setState(() {
                currentUrl = change.url!;
                isNavigatingToApp = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            print('Facebook WebView - Error: ${error.description}');
            print('Facebook WebView - Error Code: ${error.errorCode}');
            print('Facebook WebView - Error URL: ${error.url}');

            // Only show error if it's not an expected error and we haven't loaded successfully
            if (!_isExpectedError(error) &&
                !hasLoadedSuccessfully &&
                !isNavigatingToApp) {
              if (mounted) {
                setState(() {
                  isLoading = false;
                  hasError = true;
                  errorMessage = error.description;
                });
                _loaderTimer?.cancel();
                _fallbackTimer?.cancel();
                _progressTimer?.cancel();
              }
            } else if (_isExpectedError(error)) {
              print(
                  'Facebook WebView - Ignoring expected error: ${error.errorCode}');
            }
          },
          onProgress: (int progress) {
            print('Facebook WebView - Loading Progress: $progress%');
            setState(() {
              loadingProgress = progress;
              lastProgressUpdate = DateTime.now().millisecondsSinceEpoch;
            });

            // If progress is high enough, consider it loaded
            if (progress >= 85 &&
                isLoading &&
                !hasLoadedSuccessfully &&
                !isNavigatingToApp) {
              print(
                  'Facebook WebView - High progress detected ($progress%), considering loaded');
              setState(() {
                isLoading = false;
                hasLoadedSuccessfully = true;
              });
              _loaderTimer?.cancel();
              _fallbackTimer?.cancel();
              _progressTimer?.cancel();
            } else if (progress >= 80 &&
                isLoading &&
                !hasLoadedSuccessfully &&
                !isNavigatingToApp) {
              // Start a timer to check if progress gets stuck
              _startProgressStuckTimer();
            }
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

    // Add multiple fallback timers to check if page is actually loaded
    _fallbackTimer = Timer(const Duration(seconds: 8), () async {
      if (mounted &&
          isLoading &&
          !hasLoadedSuccessfully &&
          !isNavigatingToApp) {
        print(
            'Facebook WebView - Fallback 1: Checking if page actually loaded after 8 seconds');
        try {
          String? title = await _controller.getTitle();
          print('Facebook WebView - Fallback 1: Page title after 8s: $title');
          if (title != null && title.isNotEmpty && title != 'Google') {
            print(
                'Facebook WebView - Fallback 1: Page seems loaded, forcing finish');
            setState(() {
              isLoading = false;
              hasLoadedSuccessfully = true;
            });
            _loaderTimer?.cancel();
            _fallbackTimer?.cancel();
            _progressTimer?.cancel();
            await _checkBlockOrCaptcha();
          }
        } catch (e) {
          print('Facebook WebView - Fallback 1: Error checking title: $e');
        }
      }
    });

    // Second fallback timer
    Timer(const Duration(seconds: 15), () async {
      if (mounted &&
          isLoading &&
          !hasLoadedSuccessfully &&
          !isNavigatingToApp) {
        print(
            'Facebook WebView - Fallback 2: Checking if page actually loaded after 15 seconds');
        try {
          String? title = await _controller.getTitle();
          print('Facebook WebView - Fallback 2: Page title after 15s: $title');
          if (title != null && title.isNotEmpty) {
            print(
                'Facebook WebView - Fallback 2: Page seems loaded, forcing finish');
            setState(() {
              isLoading = false;
              hasLoadedSuccessfully = true;
            });
            _loaderTimer?.cancel();
            _fallbackTimer?.cancel();
            _progressTimer?.cancel();
            await _checkBlockOrCaptcha();
          }
        } catch (e) {
          print('Facebook WebView - Fallback 2: Error checking title: $e');
        }
      }
    });

    // Third fallback timer for stuck progress
    Timer(const Duration(seconds: 12), () async {
      if (mounted &&
          isLoading &&
          !hasLoadedSuccessfully &&
          loadingProgress >= 85 &&
          !isNavigatingToApp) {
        print(
            'Facebook WebView - Fallback 3: Progress stuck at $loadingProgress%, forcing completion');
        setState(() {
          isLoading = false;
          hasLoadedSuccessfully = true;
        });
        _loaderTimer?.cancel();
        _fallbackTimer?.cancel();
        _progressTimer?.cancel();
        await _checkBlockOrCaptcha();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print(
        'Facebook WebView - Build: isLoading=$isLoading, hasError=$hasError, hasLoadedSuccessfully=$hasLoadedSuccessfully, progress=$loadingProgress%, isNavigatingToApp=$isNavigatingToApp');

    bool isProfileUrl =
        currentUrl != null && _isFacebookProfileUrl(currentUrl!);
    bool isFacebookUrl =
        currentUrl != null && currentUrl!.contains('facebook.com');

    return Scaffold(
      appBar: AppBar(
        title: Text('Search: ${widget.searchQuery}'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (isProfileUrl)
            IconButton(
              onPressed: () => _showAddFriendDialog(),
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
                        ? 'Facebook is blocking this browser or showing a captcha.'
                        : 'Facebook blocked the WebView',
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
                        loadingProgress = 0;
                        isNavigatingToApp = false;
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
          if (isLoading && !hasError && !isNavigatingToApp)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.8),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: loadingProgress / 100,
                        backgroundColor: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading Facebook...',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$loadingProgress%',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      if (loadingProgress >= 85) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Almost done...',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                      ],
                      if (currentUrl != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'URL: ${currentUrl!.length > 50 ? '${currentUrl!.substring(0, 50)}...' : currentUrl!}',
                          style:
                              const TextStyle(fontSize: 10, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: isProfileUrl
          ? FloatingActionButton(
              onPressed: () => _showAddFriendDialog(),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              child: const Icon(Icons.person_add),
            )
          : FloatingActionButton(
              onPressed: () => _showNotProfileMessage(),
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              child: const Icon(Icons.info),
            ),
    );
  }

  bool _isFacebookProfileUrl(String url) {
    // More specific check for Facebook profile URLs
    if (!url.contains('facebook.com')) return false;

    // Check for specific profile patterns
    if (url.contains('/profile.php?id=')) return true;
    if (url.contains('/people/')) return true;
    if (url.contains('/profile/')) return true;

    // Check for username-based profiles (facebook.com/username)
    if (url.contains('facebook.com/') && !url.contains('facebook.com/pages/')) {
      String path = url.split('facebook.com/')[1];
      if (path.isNotEmpty) {
        String username = path.split('?')[0].split('/')[0];
        // Exclude common Facebook pages that are not profiles
        List<String> excludedPages = [
          'home',
          'profile',
          'pages',
          'groups',
          'events',
          'marketplace',
          'watch',
          'gaming',
          'jobs',
          'fundraisers',
          'developers',
          'privacy',
          'terms',
          'help',
          'about',
          'ads',
          'business',
          'login',
          'signup',
          'recover',
          'checkpoint',
          'save',
          'bookmarks'
        ];
        return !excludedPages.contains(username.toLowerCase());
      }
    }

    return false;
  }

  void _showAddFriendDialog() async {
    final nameController = TextEditingController();

    // Get the current URL directly from the WebView controller
    String? actualCurrentUrl;
    try {
      actualCurrentUrl = await _controller.currentUrl();
    } catch (e) {
      actualCurrentUrl = currentUrl;
    }

    // Handle null currentUrl
    String extractedName = '';
    if (actualCurrentUrl != null) {
      extractedName =
          _extractNameFromUrl(actualCurrentUrl) ?? widget.searchQuery;
    } else {
      extractedName = widget.searchQuery;
    }

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
                  'Current URL: ${actualCurrentUrl ?? "Loading..."}',
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
                  _addFriendToIcon(
                      nameController.text.trim(), actualCurrentUrl);
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
    // Use current URL or fallback to search URL
    String finalProfileUrl = profileUrl ??
        'https://www.facebook.com/search/top/?q=${Uri.encodeComponent(friendName)}';

    // Add to the Facebook controller with category information
    final controller = Get.find<FaceBookController>();
    controller.addFriendToCategory(
        friendName, widget.iconName, finalProfileUrl);

    // Close the dialog first
    Get.back();

    // Show success message
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

    // Navigate back to the icon screen after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      Get.back();
    });
  }

  String? _extractNameFromUrl(String url) {
    // Try to extract name from Facebook URL
    if (url.contains('facebook.com/')) {
      String path = url.split('facebook.com/')[1];
      if (path.isNotEmpty) {
        // Remove query parameters and get the username
        String username = path.split('?')[0].split('/')[0];
        if (username != 'profile.php' && username != 'pages') {
          return username.replaceAll('-', ' ').replaceAll('_', ' ');
        }
      }
    }
    return null;
  }

  void _showNotProfileMessage() {
    Get.snackbar(
      'Not a Profile URL',
      'This URL is not a Facebook profile page. Cannot add friend directly.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
    );
  }
}
