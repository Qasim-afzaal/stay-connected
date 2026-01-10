import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:stay_connected/Platform/youtube/youtube_controller.dart';

class YouTubeWebviewScreen extends StatefulWidget {
  final String searchQuery;
  final String iconName;
  final String platformName;

  const YouTubeWebviewScreen({
    super.key,
    required this.searchQuery,
    required this.iconName,
    required this.platformName,
  });

  @override
  State<YouTubeWebviewScreen> createState() => _YouTubeWebviewScreenState();
}

class _YouTubeWebviewScreenState extends State<YouTubeWebviewScreen> {
  InAppWebViewController? webViewController;
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
    print('YouTube WebView - Starting 25 second timeout timer');
    _loaderTimer = Timer(const Duration(seconds: 25), () {
      print('YouTube WebView - TIMEOUT: Loading took longer than 25 seconds');
      if (mounted &&
          isLoading &&
          !hasLoadedSuccessfully &&
          !isNavigatingToApp) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage =
              'Loading timed out. YouTube may be blocking this browser.';
        });
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
            'YouTube WebView - Progress stuck at $loadingProgress%, forcing completion');
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
    print('YouTube WebView - Checking for block/captcha...');
    try {
      String? title = await webViewController?.getTitle();
      String url = currentUrl ?? '';
      print('YouTube WebView - Page title: $title');
      print('YouTube WebView - Current URL: $url');

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
            'YouTube WebView - BLOCK DETECTED: Title or URL contains block indicators');
        setState(() {
          isBlocked = true;
          isLoading = false;
          hasError = true;
          errorMessage =
              'YouTube is blocking this browser or showing a captcha.';
        });
      } else {
        print('YouTube WebView - No block detected, page appears normal');
      }
    } catch (e) {
      print('YouTube WebView - Error checking block/captcha: $e');
    }
  }

  bool _isExpectedError(int? errorCode) {
    return errorCode == -1002 ||
        errorCode == -999 ||
        errorCode == -1001;
  }

  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    print('YouTube WebView - Initializing WebView controller');

    _fallbackTimer = Timer(const Duration(seconds: 8), () async {
      if (mounted &&
          isLoading &&
          !hasLoadedSuccessfully &&
          !isNavigatingToApp) {
        print(
            'YouTube WebView - Fallback 1: Checking if page actually loaded after 8 seconds');
        try {
          String? title = await webViewController?.getTitle();
          print('YouTube WebView - Fallback 1: Page title after 8s: $title');
          if (title != null && title.isNotEmpty && title != 'Google') {
            print(
                'YouTube WebView - Fallback 1: Page seems loaded, forcing finish');
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
          print('YouTube WebView - Fallback 1: Error checking title: $e');
        }
      }
    });

    Timer(const Duration(seconds: 15), () async {
      if (mounted &&
          isLoading &&
          !hasLoadedSuccessfully &&
          !isNavigatingToApp) {
        print(
            'YouTube WebView - Fallback 2: Checking if page actually loaded after 15 seconds');
        try {
          String? title = await webViewController?.getTitle();
          print('YouTube WebView - Fallback 2: Page title after 15s: $title');
          if (title != null && title.isNotEmpty) {
            print(
                'YouTube WebView - Fallback 2: Page seems loaded, forcing finish');
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
          print('YouTube WebView - Fallback 2: Error checking title: $e');
        }
      }
    });

    Timer(const Duration(seconds: 12), () async {
      if (mounted &&
          isLoading &&
          !hasLoadedSuccessfully &&
          loadingProgress >= 85 &&
          !isNavigatingToApp) {
        print(
            'YouTube WebView - Fallback 3: Progress stuck at $loadingProgress%, forcing completion');
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

  String _getInitialUrl() {
    String query = widget.searchQuery;
    if (query.isNotEmpty) {
      query = '$query site:youtube.com';
    }
    return 'https://www.google.com/search?q=${Uri.encodeComponent(query)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    String userAgent = Platform.isIOS
        ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1'
        : 'Mozilla/5.0 (Linux; Android 10; SM-G975F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36';

    print(
        'YouTube WebView - Build: isLoading=$isLoading, hasError=$hasError, hasLoadedSuccessfully=$hasLoadedSuccessfully, progress=$loadingProgress%, isNavigatingToApp=$isNavigatingToApp');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.iconName),
        centerTitle: true,
        backgroundColor: isDark ? (theme.appBarTheme.backgroundColor ?? Colors.grey[900]) : Colors.white,
        foregroundColor: isDark ? (theme.appBarTheme.foregroundColor ?? Colors.white) : Colors.black,
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
      body: Stack(
        children: [
          if (hasError && !hasLoadedSuccessfully)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isBlocked ? Icons.block : Icons.error,
                      size: 50, color: Colors.red),
                  const SizedBox(height: 10),
                  Text(
                    isBlocked
                        ? 'YouTube is blocking this browser or showing a captcha.'
                        : 'YouTube blocks WebView access',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This is normal - YouTube doesn\'t allow WebView access',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
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
                      webViewController?.reload();
                      _startLoaderTimeout();
                    },
                    child: const Text("Retry"),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _showAddFriendDialog(),
                    child: const Text('Add Friend Anyway'),
                  ),
                ],
              ),
            )
          else
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(_getInitialUrl()),
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
              ),
              initialSettings: InAppWebViewSettings(
                userAgent: userAgent,
                javaScriptEnabled: true,
                allowsInlineMediaPlayback: true,
                mediaPlaybackRequiresUserGesture: false,
                useShouldOverrideUrlLoading: true,
              ),
              onWebViewCreated: (controller) {
                webViewController = controller;
                
                // Inject blocking script at document start
                controller.addUserScript(
                  userScript: UserScript(
                    source: '''
                      (function() {
                        if (window.youtubeBlockingLoaded) return;
                        window.youtubeBlockingLoaded = true;
                        
                        // Block all clicks that would open YouTube app
                        document.addEventListener('click', function(e) {
                          let target = e.target;
                          let depth = 0;
                          while (target && target !== document && depth < 10) {
                            if (target.tagName === 'A' && target.href) {
                              const href = target.href.toLowerCase();
                              if (href.startsWith('youtube://') ||
                                  href.startsWith('youtubewatch://') ||
                                  href.startsWith('youtubeembed://') ||
                                  href.includes('applink.youtube.com') ||
                                  href.includes('apps.apple.com') ||
                                  href.includes('itunes.apple.com') ||
                                  href.startsWith('itms://') ||
                                  href.startsWith('itms-apps://') ||
                                  href.includes('play.google.com/store') ||
                                  href.startsWith('market://')) {
                                e.preventDefault();
                                e.stopPropagation();
                                e.stopImmediatePropagation();
                                return false;
                              }
                            }
                            target = target.parentElement;
                            depth++;
                          }
                        }, true);
                        
                        // Override window.open
                        const originalOpen = window.open;
                        window.open = function(url, target, features) {
                          if (url) {
                            const urlLower = url.toLowerCase();
                            if (urlLower.startsWith('youtube://') ||
                                urlLower.startsWith('youtubewatch://') ||
                                urlLower.startsWith('youtubeembed://') ||
                                urlLower.includes('applink.youtube.com') ||
                                urlLower.includes('apps.apple.com') ||
                                urlLower.includes('itunes.apple.com')) {
                              return null;
                            }
                          }
                          return originalOpen.call(window, url, target, features);
                        };
                      })();
                    ''',
                    injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                  ),
                );
              },
              onLoadStart: (controller, url) {
                print('YouTube WebView - Page Started: $url');

                if (url?.toString().startsWith('youtube://') ?? false) {
                  print(
                      'YouTube WebView - Detected YouTube app redirect, ignoring');
                  setState(() {
                    isNavigatingToApp = true;
                  });
                  return;
                }

                print('YouTube WebView - Starting loader timeout...');
                if (mounted) {
                  setState(() {
                    isLoading = true;
                    hasError = false;
                    errorMessage = null;
                    isBlocked = false;
                    currentUrl = url?.toString();
                    loadingProgress = 0;
                    lastProgressUpdate = DateTime.now().millisecondsSinceEpoch;
                    isNavigatingToApp = false;
                  });
                  _startLoaderTimeout();
                }
                
                // Inject blocking script early
                controller.evaluateJavascript(source: '''
                  (function() {
                    // Block all clicks that would open YouTube app
                    document.addEventListener('click', function(e) {
                      let target = e.target;
                      let depth = 0;
                      while (target && target !== document && depth < 10) {
                        if (target.tagName === 'A' && target.href) {
                          const href = target.href.toLowerCase();
                          if (href.startsWith('youtube://') ||
                              href.startsWith('youtubewatch://') ||
                              href.startsWith('youtubeembed://') ||
                              href.includes('applink.youtube.com') ||
                              href.includes('apps.apple.com') ||
                              href.includes('itunes.apple.com') ||
                              href.startsWith('itms://') ||
                              href.startsWith('itms-apps://') ||
                              href.includes('play.google.com/store') ||
                              href.startsWith('market://')) {
                            e.preventDefault();
                            e.stopPropagation();
                            e.stopImmediatePropagation();
                            return false;
                          }
                        }
                        target = target.parentElement;
                        depth++;
                      }
                    }, true);
                  })();
                ''');
              },
              onLoadStop: (controller, url) async {
                print('YouTube WebView - Page Finished: $url');

                if (url?.toString().startsWith('youtube://') ?? false) {
                  print('YouTube WebView - Ignoring app redirect completion');
                  return;
                }

                print('YouTube WebView - Cancelling timeout timer');
                if (mounted) {
                  setState(() {
                    isLoading = false;
                    currentUrl = url?.toString();
                    hasLoadedSuccessfully = true;
                    loadingProgress = 100;
                    isNavigatingToApp = false;
                  });
                  await _checkBlockOrCaptcha();
                  _loaderTimer?.cancel();
                  _fallbackTimer?.cancel();
                  _progressTimer?.cancel();
                }
                
                // Inject blocking script again after page loads
                await controller.evaluateJavascript(source: '''
                  (function() {
                    // Block all clicks that would open YouTube app
                    document.addEventListener('click', function(e) {
                      let target = e.target;
                      let depth = 0;
                      while (target && target !== document && depth < 10) {
                        if (target.tagName === 'A' && target.href) {
                          const href = target.href.toLowerCase();
                          if (href.startsWith('youtube://') ||
                              href.startsWith('youtubewatch://') ||
                              href.startsWith('youtubeembed://') ||
                              href.includes('applink.youtube.com') ||
                              href.includes('apps.apple.com') ||
                              href.includes('itunes.apple.com') ||
                              href.startsWith('itms://') ||
                              href.startsWith('itms-apps://') ||
                              href.includes('play.google.com/store') ||
                              href.startsWith('market://')) {
                            e.preventDefault();
                            e.stopPropagation();
                            e.stopImmediatePropagation();
                            return false;
                          }
                        }
                        target = target.parentElement;
                        depth++;
                      }
                    }, true);
                    
                    // Override window.open
                    const originalOpen = window.open;
                    window.open = function(url, target, features) {
                      if (url) {
                        const urlLower = url.toLowerCase();
                        if (urlLower.startsWith('youtube://') ||
                            urlLower.startsWith('youtubewatch://') ||
                            urlLower.startsWith('youtubeembed://') ||
                            urlLower.includes('applink.youtube.com') ||
                            urlLower.includes('apps.apple.com') ||
                            urlLower.includes('itunes.apple.com')) {
                          return null;
                        }
                      }
                      return originalOpen.call(window, url, target, features);
                    };
                  })();
                ''');
              },
              onProgressChanged: (controller, progress) {
                print('YouTube WebView - Loading Progress: $progress%');
                setState(() {
                  loadingProgress = progress.toInt();
                  lastProgressUpdate = DateTime.now().millisecondsSinceEpoch;
                });

                if (progress >= 85 &&
                    isLoading &&
                    !hasLoadedSuccessfully &&
                    !isNavigatingToApp) {
                  print(
                      'YouTube WebView - High progress detected ($progress%), considering loaded');
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
                  _startProgressStuckTimer();
                }
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final url = navigationAction.request.url?.toString() ?? '';
                final urlLower = url.toLowerCase();
                final isMainFrame = navigationAction.targetFrame?.isMainFrame ?? true;
                
                print('YouTube WebView - Navigation request to: $url (isMainFrame: $isMainFrame)');

                // Block Google OAuth/iframe URLs that cause white screens
                if (urlLower.contains('accounts.google.com') ||
                    urlLower.contains('google.com/gsi/') ||
                    urlLower.contains('google.com/oauth2/')) {
                  print('YouTube WebView - Blocking Google OAuth/iframe URL: $url');
                  return NavigationActionPolicy.CANCEL;
                }
                
                // Block applink.youtube.com URLs (Universal Links)
                if (urlLower.contains('applink.youtube.com')) {
                  print('YouTube WebView - Blocking applink URL: $url');
                  return NavigationActionPolicy.CANCEL;
                }
                
                // Block URLs with launch_app_store parameter
                if (urlLower.contains('launch_app_store=true')) {
                  print('YouTube WebView - Blocking URL with launch_app_store: $url');
                  return NavigationActionPolicy.CANCEL;
                }

                if (url.startsWith('youtube://') ||
                    url.startsWith('youtubewatch://') ||
                    url.startsWith('youtubeembed://')) {
                  print('YouTube WebView - Blocking YouTube app redirect');
                  setState(() {
                    isNavigatingToApp = true;
                  });
                  return NavigationActionPolicy.CANCEL;
                }

                // Block tracking URLs (googletagmanager.com, doubleclick.net, etc.)
                if (urlLower.contains('googletagmanager.com') ||
                    urlLower.contains('doubleclick.net') ||
                    urlLower.contains('google-analytics.com') ||
                    urlLower.contains('googleadservices.com')) {
                  print('YouTube WebView - Blocking tracking URL: $url');
                  return NavigationActionPolicy.CANCEL;
                }

                // Block app schemes and App Store URLs
                if (urlLower.contains('apps.apple.com') ||
                    urlLower.contains('itunes.apple.com') ||
                    urlLower.startsWith('itms://') ||
                    urlLower.startsWith('itms-apps://') ||
                    urlLower.contains('play.google.com/store') ||
                    urlLower.startsWith('market://')) {
                  print('YouTube WebView - Blocking app scheme/App Store URL: $url');
                  return NavigationActionPolicy.CANCEL;
                }
                
                // For main frame YouTube URLs only, ensure _webview=1&noapp=1 parameters are present
                // Don't modify iframe URLs or OAuth URLs
                if (isMainFrame &&
                    urlLower.contains('youtube.com') &&
                    !urlLower.contains('accounts.google.com') &&
                    !urlLower.contains('google.com/gsi/') &&
                    !urlLower.contains('google.com/oauth2/') &&
                    !urlLower.contains('googletagmanager.com') &&
                    !urlLower.contains('doubleclick.net') &&
                    !urlLower.contains('google-analytics.com') &&
                    !urlLower.contains('googleadservices.com') &&
                    !urlLower.contains('_webview=1') &&
                    !urlLower.contains('noapp=1')) {
                  print('YouTube WebView - Modifying URL to prevent Universal Links: $url');
                  final modifiedUrl = url.contains('?')
                      ? '$url&_webview=1&noapp=1'
                      : '$url?_webview=1&noapp=1';
                  Future.microtask(() async {
                    await controller.loadUrl(urlRequest: URLRequest(url: WebUri(modifiedUrl)));
                  });
                  return NavigationActionPolicy.CANCEL;
                }

                if (mounted) {
                  setState(() {
                    currentUrl = url;
                    isNavigatingToApp = false;
                  });
                }
                return NavigationActionPolicy.ALLOW;
              },
              onReceivedError: (controller, request, error) {
                print('YouTube WebView - Error: ${error.description}');
                print('YouTube WebView - Error Type: ${error.type}');

                // Convert error type to a numeric code for comparison
                final errorCode = error.type == WebResourceErrorType.HOST_LOOKUP ? -1002 :
                                 error.type == WebResourceErrorType.CANCELLED ? -999 :
                                 error.type == WebResourceErrorType.TIMEOUT ? -1001 : 0;

                if (!_isExpectedError(errorCode) &&
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
                } else if (_isExpectedError(errorCode)) {
                  print(
                      'YouTube WebView - Ignoring expected error: $errorCode');
                }
              },
              onReceivedServerTrustAuthRequest: (controller, challenge) async {
                return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
              },
            ),
          if (isLoading && !hasError && !isNavigatingToApp)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading: $loadingProgress%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey[400] : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          // Always show Add Friend button at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: _isOnGoogleSearch() || isLoading
                      ? null
                      : () => _showAddFriendDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.grey[800] : Colors.black,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade400,
                    disabledForegroundColor: Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_add,
                        color: (_isOnGoogleSearch() || isLoading)
                            ? Colors.grey.shade600
                            : Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isLoading
                            ? 'Loading: $loadingProgress%'
                            : 'Add Friend',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: (_isOnGoogleSearch() || isLoading)
                              ? Colors.grey.shade600
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isOnGoogleSearch() {
    final url = currentUrl?.toLowerCase() ?? '';
    return url.contains('google.com') || url.contains('googleapis.com');
  }

  void _showAddFriendDialog() async {
    // Don't show dialog if on Google search page
    if (_isOnGoogleSearch()) {
      Get.snackbar(
        'Error',
        'Please navigate to a YouTube profile page first',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final nameController = TextEditingController();
    String? actualCurrentUrl;

    try {
      if (webViewController != null) {
        actualCurrentUrl = (await webViewController!.getUrl())?.toString();
      } else {
        actualCurrentUrl = currentUrl;
      }
    } catch (e) {
      actualCurrentUrl = currentUrl;
    }

    // Double check it's not a Google search page
    if (_isOnGoogleSearch()) {
      Get.snackbar(
        'Error',
        'Please navigate to a YouTube profile page first',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    String extractedName = actualCurrentUrl != null
        ? _extractNameFromUrl(actualCurrentUrl) ?? widget.searchQuery
        : widget.searchQuery;

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
                child: const Icon(CupertinoIcons.person_add,
                    color: CupertinoColors.systemBlue, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Add Friend',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              children: [
                Text('Add this person to your ${widget.iconName} list?',
                    style: const TextStyle(
                        fontSize: 14, color: CupertinoColors.systemGrey)),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text('Current URL: ${actualCurrentUrl ?? "Loading..."}',
                    style: const TextStyle(
                        fontSize: 10, color: CupertinoColors.systemGrey2)),
              ],
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel',
                  style: TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontWeight: FontWeight.w600)),
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
              child: const Text('Add',
                  style: TextStyle(
                      color: CupertinoColors.systemBlue,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  void _addFriendToIcon(String friendName, String? profileUrl) {
    String finalProfileUrl = profileUrl ??
        'https://www.youtube.com/results?search_query=${Uri.encodeComponent(friendName)}';

    final controller = Get.find<YouTubeController>();
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
    if (url.contains('youtube.com/')) {
      String path = url.split('youtube.com/')[1];
      if (path.isNotEmpty) {
        String username = path.split('?')[0].split('/')[0];
        if (username != 'watch' && username != 'playlist' && username != 'channel' && username != 'user' && username != 'c' && username != '@') {
          return username.replaceAll('-', ' ').replaceAll('_', ' ');
        }
      }
    }
    return null;
  }
}
