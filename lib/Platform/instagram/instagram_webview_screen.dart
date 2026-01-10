import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:stay_connected/Platform/instagram/instagram_controller.dart';

class InstagramWebviewScreen extends StatefulWidget {
  final String searchQuery;
  final String iconName;
  final String platformName;

  const InstagramWebviewScreen({
    super.key,
    required this.searchQuery,
    required this.iconName,
    required this.platformName,
  });

  @override
  State<InstagramWebviewScreen> createState() => _InstagramWebviewScreenState();
}

class _InstagramWebviewScreenState extends State<InstagramWebviewScreen> {
  InAppWebViewController? webViewController;
  bool isLoading = true;
  String? currentUrl;
  int loadingProgress = 0;

  String _getInitialUrl() {
    String query = widget.searchQuery;
    if (query.isNotEmpty) {
      query = '$query site:instagram.com';
    }
    return 'https://www.google.com/search?q=${Uri.encodeComponent(query)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    String userAgent = Platform.isIOS
        ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1'
        : 'Mozilla/5.0 (Linux; Android 14; SM-G998B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';

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
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(_getInitialUrl()),
              headers: {
                'User-Agent': userAgent,
                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
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
              
              // Register JavaScript handler for post capture
              controller.addJavaScriptHandler(
                handlerName: 'InstagramPostCapture',
                callback: (args) async {
                  if (args.isNotEmpty) {
                    String postUrl = args[0].toString();
                    if (postUrl.isNotEmpty && postUrl.startsWith('http')) {
                      // Clean the URL: decode HTML entities and remove query parameters
                      postUrl = postUrl
                          .replaceAll('&amp;', '&')
                          .replaceAll('&amp;amp;', '&')
                          .replaceAll('&amp;amp;amp;', '&');
                      
                      // Remove all query parameters (everything after ?)
                      if (postUrl.contains('?')) {
                        postUrl = postUrl.split('?')[0];
                      }
                      
                      // Get current URL to prevent infinite loop
                      final currentUrl = await controller.getUrl();
                      final currentUrlString = currentUrl?.toString() ?? '';
                      
                      // Clean current URL too
                      String cleanCurrentUrl = currentUrlString;
                      if (cleanCurrentUrl.contains('?')) {
                        cleanCurrentUrl = cleanCurrentUrl.split('?')[0];
                      }
                      cleanCurrentUrl = cleanCurrentUrl.replaceAll('&amp;', '&');
                      
                      // Only load if it's different from current URL
                      if (postUrl != cleanCurrentUrl && (postUrl.contains('/p/') || postUrl.contains('/reel/') || postUrl.contains('/tv/') || postUrl.contains('/reels/'))) {
                        print('Instagram WebView - Captured post URL: $postUrl');
                        Future.microtask(() {
                          controller.loadUrl(urlRequest: URLRequest(url: WebUri(postUrl)));
                        });
                      } else {
                        print('Instagram WebView - Ignoring duplicate URL: $postUrl');
                      }
                    }
                  }
                },
              );
              
              // Inject blocking and post capture script at document start
              controller.addUserScript(
                userScript: UserScript(
                  source: '''
                    (function() {
                      if (window.instagramBlockingLoaded) return;
                      window.instagramBlockingLoaded = true;
                      
                      // Allow normal navigation for posts/reels/images - just ensure URLs have _webview=1&noapp=1
                      function ensureWebViewParams(e) {
                        try {
                          let target = e.target;
                          let depth = 0;
                          while (target && target !== document && depth < 10) {
                            if (target.tagName === 'A' && target.href) {
                              const href = target.href;
                              if (href.includes('instagram.com') && (href.includes('/p/') || href.includes('/reel/') || href.includes('/tv/') || href.includes('/reels/'))) {
                                if (!href.includes('_webview=1') || !href.includes('noapp=1')) {
                                  const separator = href.includes('?') ? '&' : '?';
                                  target.href = href + separator + '_webview=1&noapp=1';
                                }
                                return;
                              }
                            }
                            target = target.parentElement;
                            depth++;
                          }
                        } catch(err) {}
                      }
                      
                      // Allow app scheme redirects for Instagram content (posts, reels, images) - let them open in native app
                      // Only block App Store URLs
                      document.addEventListener('click', function(e) {
                        let target = e.target;
                        let depth = 0;
                        while (target && target !== document && depth < 10) {
                          if (target.tagName === 'A' && target.href) {
                            const href = target.href.toLowerCase();
                            // Block only App Store URLs - allow everything else including app schemes
                            if (href.includes('apps.apple.com') ||
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
                            // Allow all other navigation (including app schemes for Instagram content)
                            return;
                          }
                          target = target.parentElement;
                          depth++;
                        }
                      }, false);
                      
                      // Allow normal navigation for posts/reels/images - just ensure URLs have _webview=1&noapp=1
                      function ensureWebViewParams(e) {
                        try {
                          let target = e.target;
                          let depth = 0;
                          while (target && target !== document && depth < 10) {
                            if (target.tagName === 'A' && target.href) {
                              const href = target.href;
                              if (href.includes('instagram.com') && (href.includes('/p/') || href.includes('/reel/') || href.includes('/tv/') || href.includes('/reels/'))) {
                                if (!href.includes('_webview=1') || !href.includes('noapp=1')) {
                                  const separator = href.includes('?') ? '&' : '?';
                                  target.href = href + separator + '_webview=1&noapp=1';
                                }
              return;
            }
                            }
                            target = target.parentElement;
                            depth++;
                          }
                        } catch(err) {}
                      }
                      
                      document.addEventListener('click', ensureWebViewParams, true);
                      document.addEventListener('touchend', ensureWebViewParams, true);
                      
                      // Override window.open
                      const originalOpen = window.open;
                      window.open = function(url, target, features) {
                        if (url) {
                          const urlLower = url.toLowerCase();
                          if (urlLower.startsWith('instagram://') ||
                              urlLower.startsWith('fb://') ||
                              urlLower.startsWith('fbapi://') ||
                              urlLower.includes('applink.instagram.com') ||
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
              print('Instagram WebView - Page Started: $url');

              if (url?.toString().startsWith('instagram://') ?? false) {
                print('Instagram WebView - Detected Instagram app redirect, ignoring');
                return;
              }

            if (mounted) {
              setState(() {
                isLoading = true;
                  currentUrl = url?.toString();
                loadingProgress = 0;
                });
              }
              
              // Inject blocking and post capture script early
              controller.evaluateJavascript(source: '''
                (function() {
                  // Allow normal navigation for posts/reels/images - just ensure URLs have _webview=1&noapp=1
                  function ensureWebViewParams(e) {
                    try {
                      let target = e.target;
                      let depth = 0;
                      while (target && target !== document && depth < 10) {
                        if (target.tagName === 'A' && target.href) {
                          const href = target.href;
                          if (href.includes('instagram.com') && (href.includes('/p/') || href.includes('/reel/') || href.includes('/tv/') || href.includes('/reels/'))) {
                            if (!href.includes('_webview=1') || !href.includes('noapp=1')) {
                              const separator = href.includes('?') ? '&' : '?';
                              target.href = href + separator + '_webview=1&noapp=1';
                            }
                            return;
                          }
                        }
                        target = target.parentElement;
                        depth++;
                      }
                    } catch(err) {}
                  }
                  
                  document.addEventListener('click', ensureWebViewParams, true);
                  document.addEventListener('touchend', ensureWebViewParams, true);
                  
                  // Block only app scheme redirects - allow all normal navigation including posts/reels
                  document.addEventListener('click', function(e) {
                    let target = e.target;
                    let depth = 0;
                    while (target && target !== document && depth < 10) {
                      if (target.tagName === 'A' && target.href) {
                        const href = target.href.toLowerCase();
                        if (href.startsWith('instagram://') ||
                            href.startsWith('fb://') ||
                            href.startsWith('fbapi://') ||
                            href.includes('applink.instagram.com') ||
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
              print('Instagram WebView - Page Finished: $url');

              if (url?.toString().startsWith('instagram://') ?? false) {
                print('Instagram WebView - Ignoring app redirect completion');
                return;
              }

            if (mounted) {
              setState(() {
                isLoading = false;
                  currentUrl = url?.toString();
                loadingProgress = 100;
                });
              }
              
              // Inject blocking and post capture script again after page loads
              await controller.evaluateJavascript(source: '''
                (function() {
                  // Allow normal navigation for posts/reels/images - just ensure URLs have _webview=1&noapp=1
                  function ensureWebViewParams(e) {
                    try {
                      let target = e.target;
                      let depth = 0;
                      while (target && target !== document && depth < 10) {
                        if (target.tagName === 'A' && target.href) {
                          const href = target.href;
                          if (href.includes('instagram.com') && (href.includes('/p/') || href.includes('/reel/') || href.includes('/tv/') || href.includes('/reels/'))) {
                            if (!href.includes('_webview=1') || !href.includes('noapp=1')) {
                              const separator = href.includes('?') ? '&' : '?';
                              target.href = href + separator + '_webview=1&noapp=1';
                            }
                return;
              }
                        }
                        target = target.parentElement;
                        depth++;
                      }
                    } catch(err) {}
                  }
                  
                  document.addEventListener('click', ensureWebViewParams, true);
                  document.addEventListener('touchend', ensureWebViewParams, true);
                  
                  // Block only app scheme redirects - allow all normal navigation including posts/reels
                  document.addEventListener('click', function(e) {
                    let target = e.target;
                    let depth = 0;
                    while (target && target !== document && depth < 10) {
                      if (target.tagName === 'A' && target.href) {
                        const href = target.href.toLowerCase();
                        if (href.startsWith('instagram://') ||
                            href.startsWith('fb://') ||
                            href.startsWith('fbapi://') ||
                            href.includes('applink.instagram.com') ||
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
                  
                  // Override window.open - allow app schemes for Instagram content
                  const originalOpen = window.open;
                  window.open = function(url, target, features) {
                    if (url) {
                      const urlLower = url.toLowerCase();
                      // Block only App Store URLs - allow app schemes for Instagram content
                      if (urlLower.includes('apps.apple.com') ||
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
            print('Instagram WebView - Loading Progress: $progress%');
            setState(() {
                loadingProgress = progress.toInt();
                if (progress >= 100) {
                isLoading = false;
                }
              });
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final url = navigationAction.request.url?.toString() ?? '';
              final urlLower = url.toLowerCase();
              final isMainFrame = navigationAction.targetFrame?.isMainFrame ?? true;
              
              print('Instagram WebView - Navigation request to: $url (isMainFrame: $isMainFrame)');

              // Block Google OAuth/iframe URLs that cause white screens
              if (urlLower.contains('accounts.google.com') ||
                  urlLower.contains('google.com/gsi/') ||
                  urlLower.contains('google.com/oauth2/')) {
                print('Instagram WebView - Blocking Google OAuth/iframe URL: $url');
                return NavigationActionPolicy.CANCEL;
              }
              
              // Block applink.instagram.com URLs (Universal Links)
              if (urlLower.contains('applink.instagram.com')) {
                print('Instagram WebView - Blocking applink URL: $url');
                return NavigationActionPolicy.CANCEL;
              }
              
              // Block URLs with launch_app_store parameter
              if (urlLower.contains('launch_app_store=true')) {
                print('Instagram WebView - Blocking URL with launch_app_store: $url');
                return NavigationActionPolicy.CANCEL;
              }
              
              // Allow app schemes for Instagram content (posts, reels, profiles, images)
              // Let them redirect to the native app
              if (urlLower.startsWith('instagram://') ||
                  urlLower.startsWith('fb://') ||
                  urlLower.startsWith('fbapi://')) {
                print('Instagram WebView - Allowing app redirect for Instagram content: $url');
                return NavigationActionPolicy.ALLOW;
              }
              
              // Block only App Store URLs and other non-Instagram app schemes
              if (urlLower.startsWith('itms://') ||
                  urlLower.startsWith('itms-apps://') ||
                  urlLower.startsWith('market://')) {
                print('Instagram WebView - Blocking App Store/market URL: $url');
                return NavigationActionPolicy.CANCEL;
              }
              
              // Block App Store URLs only if they're direct (not in redirect parameters)
              if ((urlLower.startsWith('apps.apple.com') ||
                  urlLower.startsWith('itunes.apple.com') ||
                  urlLower.startsWith('play.google.com/store')) &&
                  !urlLower.contains('instagram.com') &&
                  !urlLower.contains('/p/') &&
                  !urlLower.contains('/reel/') &&
                  !urlLower.contains('/tv/')) {
                print('Instagram WebView - Blocking App Store URL: $url');
                return NavigationActionPolicy.CANCEL;
              }
              
              // For main frame Instagram URLs only, ensure _webview=1&noapp=1 parameters are present
              // Don't modify iframe URLs or OAuth URLs
              if (isMainFrame &&
                  urlLower.contains('instagram.com') &&
                  !urlLower.contains('accounts.google.com') &&
                  !urlLower.contains('google.com/gsi/') &&
                  !urlLower.contains('google.com/oauth2/') &&
                  !urlLower.contains('_webview=1') &&
                  !urlLower.contains('noapp=1')) {
                print('Instagram WebView - Modifying URL to prevent Universal Links: $url');
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
                });
              }
              return NavigationActionPolicy.ALLOW;
            },
            onReceivedServerTrustAuthRequest: (controller, challenge) async {
              return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
            },
          ),
          if (isLoading)
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
        'Please navigate to an Instagram profile page first',
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
        'Please navigate to an Instagram profile page first',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

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
    String finalProfileUrl = profileUrl ??
        'https://www.instagram.com/explore/tags/${Uri.encodeComponent(friendName)}/';

    final controller = Get.find<InstagramController>();
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
    if (url.contains('instagram.com/')) {
      String path = url.split('instagram.com/')[1];
      if (path.isNotEmpty) {
        String username = path.split('?')[0].split('/')[0];
        if (username != 'explore' &&
            username != 'reels' &&
            username != 'direct') {
          return username.replaceAll('-', ' ').replaceAll('_', ' ');
        }
      }
    }
    return null;
  }
}
