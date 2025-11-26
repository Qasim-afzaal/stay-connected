import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// Import all platform controllers
import 'package:stay_connected/Platform/facebook/facebook_controller.dart';
import 'package:stay_connected/Platform/instagram/instagram_controller.dart';
import 'package:stay_connected/Platform/pinterest/pinterest_controller.dart';
import 'package:stay_connected/Platform/reddit/reddit_controller.dart';
import 'package:stay_connected/Platform/snapchat/snapchat_controller.dart';
import 'package:stay_connected/Platform/tiktok/tiktok_controller.dart';
import 'package:stay_connected/Platform/twitter/twitter_controller.dart';
import 'package:stay_connected/Platform/youtube/youtube_controller.dart';

class ProfileWebViewScreen extends StatefulWidget {
  final String platform;
  final String searchQuery;
  final String iconName;

  const ProfileWebViewScreen({
    super.key,
    required this.platform,
    required this.searchQuery,
    required this.iconName,
  });

  @override
  State<ProfileWebViewScreen> createState() => _ProfileWebViewScreenState();
}

class _ProfileWebViewScreenState extends State<ProfileWebViewScreen> {
  bool isLoading = true;
  String? currentUrl;

  // Get blocked schemes for platform
  List<String> _getBlockedSchemes() {
    final platformLower = widget.platform.toLowerCase();
    switch (platformLower) {
      case 'facebook':
        return ['fb://', 'fbapi://', 'fbauth2://', 'fbshareextension://', 'intent://'];
      case 'twitter':
        return ['twitter://', 'tweetie://', 'x://', 'intent://'];
      case 'instagram':
        return ['instagram://', 'instagram-stories://', 'fb://', 'fbapi://', 'intent://'];
      case 'tiktok':
        return ['tiktok://', 'snssdk1233://', 'snssdk1180://', 'snssdk://', 'musical://', 'tt://', 'intent://'];
      case 'pinterest':
        return ['pinterest://', 'intent://'];
      case 'reddit':
        return ['reddit://', 'intent://'];
      case 'snapchat':
        return ['snapchat://', 'intent://'];
      case 'youtube':
        return ['youtube://', 'youtubewatch://', 'youtubeembed://', 'intent://'];
      default:
        return ['intent://'];
    }
  }

  // Generate blocking script - MUST run before any page scripts
  String _getBlockingScript() {
    final blockedSchemes = _getBlockedSchemes();
    final schemesList = blockedSchemes.map((s) => "'$s'").join(', ');
    final platformLower = widget.platform.toLowerCase();
    final isTikTok = platformLower == 'tiktok';
    
    return '''
      (function() {
        // CRITICAL: Run IMMEDIATELY before any page scripts
        try {
          const blockedSchemes = [$schemesList];
          const isTikTok = $isTikTok;
          
          // Block meta refresh redirects
          const metaTags = document.querySelectorAll('meta[http-equiv="refresh"]');
          metaTags.forEach(meta => {
            const content = meta.getAttribute('content') || '';
            if (content.includes('url=')) {
              const url = content.split('url=')[1].split(';')[0].trim();
              const urlLower = url.toLowerCase();
              if (blockedSchemes.some(scheme => urlLower.startsWith(scheme)) ||
                  urlLower.includes('apps.apple.com') ||
                  urlLower.includes('itunes.apple.com')) {
                meta.remove();
              }
            }
          });
          
          // Only override location for TikTok (aggressive blocking needed)
          // For other platforms, use lighter blocking
          if (isTikTok) {
            try {
              // Override location IMMEDIATELY - only for TikTok
              const locationDescriptor = Object.getOwnPropertyDescriptor(window, 'location');
              if (locationDescriptor && locationDescriptor.configurable) {
                const originalLocationHref = locationDescriptor.get;
                Object.defineProperty(window, 'location', {
                  get: function() {
                    const loc = originalLocationHref.call(window);
                    const originalHrefGetter = Object.getOwnPropertyDescriptor(loc, 'href');
                    if (originalHrefGetter && originalHrefGetter.configurable) {
                      const originalReplace = loc.replace;
                      const originalAssign = loc.assign;
                      
                      Object.defineProperty(loc, 'href', {
                        get: originalHrefGetter.get,
                        set: function(url) {
                          const urlLower = (url || '').toLowerCase();
                          if (blockedSchemes.some(scheme => urlLower.startsWith(scheme)) ||
                              urlLower.includes('apps.apple.com') ||
                              urlLower.includes('itunes.apple.com') ||
                              urlLower.startsWith('itms://') ||
                              urlLower.startsWith('itms-apps://') ||
                              (!urlLower.startsWith('http://') && !urlLower.startsWith('https://') && !urlLower.startsWith('javascript:') && !urlLower.startsWith('about:'))) {
                            console.log('BLOCKED location.href:', url);
                            return;
                          }
                          originalHrefGetter.set.call(loc, url);
                        },
                        configurable: true
                      });
                      
                      loc.replace = function(url) {
                        const urlLower = (url || '').toLowerCase();
                        if (blockedSchemes.some(scheme => urlLower.startsWith(scheme)) ||
                            urlLower.includes('apps.apple.com') ||
                            urlLower.includes('itunes.apple.com') ||
                            urlLower.startsWith('itms://') ||
                            urlLower.startsWith('itms-apps://')) {
                          console.log('BLOCKED location.replace:', url);
                          return;
                        }
                        return originalReplace.call(loc, url);
                      };
                      
                      loc.assign = function(url) {
                        const urlLower = (url || '').toLowerCase();
                        if (blockedSchemes.some(scheme => urlLower.startsWith(scheme)) ||
                            urlLower.includes('apps.apple.com') ||
                            urlLower.includes('itunes.apple.com') ||
                            urlLower.startsWith('itms://') ||
                            urlLower.startsWith('itms-apps://')) {
                          console.log('BLOCKED location.assign:', url);
                          return;
                        }
                        return originalAssign.call(loc, url);
                      };
                    }
                    
                    return loc;
                  },
                  configurable: true
                });
              }
            } catch(e) {
              console.log('Could not override location (non-configurable):', e);
            }
          }
          
          // Override window.open
          const originalOpen = window.open;
          window.open = function(url, target, features) {
            if (url) {
              const urlLower = url.toLowerCase();
              if (blockedSchemes.some(scheme => urlLower.startsWith(scheme)) ||
                  urlLower.includes('apps.apple.com') ||
                  urlLower.includes('itunes.apple.com') ||
                  urlLower.startsWith('itms://') ||
                  urlLower.startsWith('itms-apps://')) {
                console.log('BLOCKED window.open:', url);
                return null;
              }
            }
            return originalOpen.call(window, url, target, features);
          };
          
          // Intercept ALL events - lighter blocking for non-TikTok platforms
          function blockAppRedirects(e) {
            let target = e.target;
            let depth = 0;
            while (target && target !== document && depth < 15) {
              const href = target.href || target.getAttribute('href') || target.getAttribute('data-href') || '';
              const onclick = target.getAttribute('onclick') || '';
              const allUrls = (href + ' ' + onclick).toLowerCase();
              
              // Only block app schemes and App Store - allow normal navigation
              if (blockedSchemes.some(scheme => allUrls.startsWith(scheme)) ||
                  allUrls.includes('apps.apple.com') ||
                  allUrls.includes('itunes.apple.com') ||
                  allUrls.startsWith('itms://') ||
                  allUrls.startsWith('itms-apps://')) {
                e.preventDefault();
                e.stopPropagation();
                e.stopImmediatePropagation();
                target.style.pointerEvents = 'none';
                if (target.tagName === 'A') {
                  target.href = 'javascript:void(0)';
                }
                return false;
              }
              
              target = target.parentElement;
              depth++;
            }
          }
          
          // Add listeners at capture phase
          // Only add aggressive listeners for TikTok
          if (isTikTok) {
            document.addEventListener('click', blockAppRedirects, true);
            document.addEventListener('touchend', blockAppRedirects, true);
            document.addEventListener('touchstart', blockAppRedirects, true);
            document.addEventListener('mousedown', blockAppRedirects, true);
          } else {
            // Lighter blocking for other platforms - only block app schemes
            document.addEventListener('click', function(e) {
              const target = e.target.closest('a');
              if (target && target.href) {
                const href = target.href.toLowerCase();
                if (blockedSchemes.some(scheme => href.startsWith(scheme)) ||
                    href.includes('apps.apple.com') ||
                    href.includes('itunes.apple.com') ||
                    href.startsWith('itms://') ||
                    href.startsWith('itms-apps://')) {
                  e.preventDefault();
                  e.stopPropagation();
                  return false;
                }
              }
            }, true);
          }
          
          // Watch for dynamically added elements
          const observer = new MutationObserver(function(mutations) {
            mutations.forEach(function(mutation) {
              mutation.addedNodes.forEach(function(node) {
                if (node.nodeType === 1) {
                  if (node.tagName === 'A') {
                    const href = node.href || node.getAttribute('href') || '';
                    if (href && blockedSchemes.some(scheme => href.toLowerCase().startsWith(scheme))) {
                      node.style.pointerEvents = 'none';
                      node.href = 'javascript:void(0)';
                    }
                  }
                  // Only add aggressive listeners for TikTok
                  if (isTikTok) {
                    node.addEventListener('click', blockAppRedirects, true);
                    node.addEventListener('touchend', blockAppRedirects, true);
                  }
                }
              });
            });
          });
          
          if (document.body) {
            observer.observe(document.body, { childList: true, subtree: true });
        } else {
            document.addEventListener('DOMContentLoaded', function() {
              if (document.body) {
                observer.observe(document.body, { childList: true, subtree: true });
              }
            });
          }
        } catch(e) {
          console.error('Blocking script error:', e);
        }
      })();
    ''';
  }

  // Check if URL should be blocked
  bool _shouldBlockUrl(String url) {
    final urlLower = url.toLowerCase();
    final blockedSchemes = _getBlockedSchemes();
    
    // Block app schemes
    for (var scheme in blockedSchemes) {
      if (urlLower.startsWith(scheme)) {
        return true;
      }
    }
    
    // Block App Store URLs
    if (urlLower.contains('apps.apple.com') ||
        urlLower.contains('itunes.apple.com') ||
        urlLower.startsWith('itms://') ||
        urlLower.startsWith('itms-apps://') ||
        urlLower.contains('play.google.com/store') ||
        urlLower.startsWith('market://')) {
      return true;
    }
    
    // Block non-HTTP/HTTPS URLs
    if (!urlLower.startsWith('http://') && 
        !urlLower.startsWith('https://') && 
        !urlLower.startsWith('about:') &&
        !urlLower.startsWith('data:') &&
        !urlLower.startsWith('javascript:')) {
      return true;
    }
    
    return false;
  }

  String _getInitialUrl() {
    String query = widget.searchQuery;
    final platform = widget.platform.toLowerCase();

    if (query.isNotEmpty) {
      switch (platform) {
        case 'facebook':
          query = '$query site:facebook.com';
          break;
        case 'youtube':
          query = '$query site:youtube.com';
          break;
        case 'twitter':
          query = '$query site:twitter.com OR site:x.com';
          break;
        case 'instagram':
          query = '$query site:instagram.com';
          break;
        case 'reddit':
          query = '$query site:reddit.com';
          break;
        case 'pinterest':
          query = '$query site:pinterest.com';
          break;
        case 'snapchat':
          query = '$query site:snapchat.com';
          break;
        case 'tiktok':
          query = '$query site:tiktok.com';
          break;
        default:
          query = '$query site:$platform.com';
          break;
      }

      return 'https://www.google.com/search?q=${Uri.encodeComponent(query)}';
    } else {
      return 'https://$platform.com';
    }
  }

  String _getUserAgent() {
    if (Platform.isIOS) {
      return 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1';
    } else {
      return 'Mozilla/5.0 (Linux; Android 14; SM-G998B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAgent = _getUserAgent();
    final blockingScript = _getBlockingScript();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Select ${widget.platform} Profile'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: WebUri(_getInitialUrl()),
                    headers: {
                      'User-Agent': userAgent,
                      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                      'Accept-Language': 'en-US,en;q=0.9',
                    },
                  ),
                  initialSettings: InAppWebViewSettings(
                    userAgent: userAgent,
                    javaScriptEnabled: true,
                    useShouldOverrideUrlLoading: true,
                    // CRITICAL: Disable Universal Links on iOS
                    disableDefaultErrorPage: true,
                    allowsInlineMediaPlayback: true,
                    mediaPlaybackRequiresUserGesture: false,
                  ),
                  onWebViewCreated: (controller) async {
                    // CRITICAL: Add user script that runs BEFORE page scripts
                    await controller.addUserScript(
                      userScript: UserScript(
                        source: blockingScript,
                        injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                      ),
                    );
                  },
                  onLoadStart: (controller, url) {
                    print('ProfileWebView - Load Start: $url');
                    setState(() {
                      isLoading = true;
                      currentUrl = url?.toString();
                    });
                    
                    // Block app redirects immediately
                    if (url != null && _shouldBlockUrl(url.toString())) {
                      print('ProfileWebView - BLOCKING URL at load start: $url');
                      controller.goBack();
                      return;
                    }
                    
                    // CRITICAL: Inject blocking script IMMEDIATELY on page start
                    // This runs before Facebook's scripts can execute
                    if (url != null) {
                      controller.evaluateJavascript(source: blockingScript).catchError((e) {
                        // Ignore errors - page might not be ready
                      });
                    }
                  },
                  onLoadStop: (controller, url) async {
                    print('ProfileWebView - Load Stop: $url');
                    setState(() {
                      isLoading = false;
                      currentUrl = url?.toString();
                    });
                    
                    // CRITICAL: Inject blocking script multiple times after page loads
                    if (url != null) {
                      await controller.evaluateJavascript(source: blockingScript).catchError((e) {});
                      // Inject multiple times to catch dynamic content
                      Future.delayed(Duration(milliseconds: 50), () {
                        controller.evaluateJavascript(source: blockingScript).catchError((e) {});
                      });
                      Future.delayed(Duration(milliseconds: 100), () {
                        controller.evaluateJavascript(source: blockingScript).catchError((e) {});
                      });
                      Future.delayed(Duration(milliseconds: 300), () {
                        controller.evaluateJavascript(source: blockingScript).catchError((e) {});
                      });
                      Future.delayed(Duration(milliseconds: 500), () {
                        controller.evaluateJavascript(source: blockingScript).catchError((e) {});
                      });
                      Future.delayed(Duration(milliseconds: 1000), () {
                        controller.evaluateJavascript(source: blockingScript).catchError((e) {});
                      });
                    }
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    // Log ALL console messages to detect redirect attempts
                    final message = consoleMessage.message.toLowerCase();
                    if (message.contains('blocked') ||
                        message.contains('redirect') ||
                        message.contains('fb://') ||
                        message.contains('tiktok://') ||
                        message.contains('instagram://') ||
                        message.contains('twitter://') ||
                        message.contains('apps.apple.com')) {
                      print('ProfileWebView - Console [${consoleMessage.messageLevel}]: ${consoleMessage.message}');
                    }
                  },
                  onReceivedServerTrustAuthRequest: (controller, challenge) async {
                    // Allow all SSL certificates
                    return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
                  },
                  shouldOverrideUrlLoading: (controller, navigationAction) async {
                    final url = navigationAction.request.url?.toString() ?? '';
                    final navigationType = navigationAction.navigationType;
                    final isMainFrame = navigationAction.isForMainFrame;
                    
                    print('ProfileWebView - shouldOverrideUrlLoading: $url (type: $navigationType, mainFrame: $isMainFrame)');
                    
                    // Block TikTok redirect URLs that try to open the app
                    if (url.contains('tiktokv.com/redirect') || url.contains('tiktok.com/redirect')) {
                      print('ProfileWebView - Blocking TikTok redirect URL: $url');
                      return NavigationActionPolicy.CANCEL;
                    }
                    
                    // CRITICAL: Block ALL navigation types for app schemes
                    if (_shouldBlockUrl(url)) {
                      print('ProfileWebView - CRITICAL: BLOCKING navigation: $url');
                      return NavigationActionPolicy.CANCEL;
                    }
                    
                    // CRITICAL: Check for app schemes in all navigation types
                    final urlLower = url.toLowerCase();
                    final blockedSchemes = _getBlockedSchemes();
                    for (var scheme in blockedSchemes) {
                      if (urlLower.startsWith(scheme)) {
                        print('ProfileWebView - CRITICAL: BLOCKING app scheme ($scheme): $url');
                        return NavigationActionPolicy.CANCEL;
                      }
                    }
                    
                    // Block App Store URLs
                    if (urlLower.contains('apps.apple.com') ||
                        urlLower.contains('itunes.apple.com') ||
                        urlLower.startsWith('itms://') ||
                        urlLower.startsWith('itms-apps://') ||
                        urlLower.contains('play.google.com/store') ||
                        urlLower.startsWith('market://')) {
                      print('ProfileWebView - CRITICAL: BLOCKING App Store URL: $url');
                      return NavigationActionPolicy.CANCEL;
                    }
                    
                    // CRITICAL: Block about:blank in iframes (often used for redirects)
                    if (urlLower == 'about:blank' && !isMainFrame) {
                      print('ProfileWebView - BLOCKING about:blank in iframe');
                      return NavigationActionPolicy.CANCEL;
                    }
                    
                    // CRITICAL: For ALL social media URLs, add parameters to prevent Universal Link detection
                    // Only modify if the URL doesn't already have our prevention parameters
                    final socialMediaDomains = [
                      'facebook.com', 'fb.com',
                      'twitter.com', 'x.com',
                      'instagram.com',
                      'tiktok.com',
                      'pinterest.com',
                      'reddit.com',
                      'snapchat.com',
                      'youtube.com', 'youtu.be',
                    ];
                    
                    bool isSocialMediaUrl = false;
                    for (var domain in socialMediaDomains) {
                      if (url.contains(domain)) {
                        isSocialMediaUrl = true;
                        break;
                      }
                    }
                    
                    // If it's a social media URL and doesn't have prevention parameters, add them
                    if (isSocialMediaUrl && 
                        !url.contains('_webview=1') && 
                        !url.contains('noapp=1')) {
                      print('ProfileWebView - Modifying social media URL to prevent Universal Links: $url');
                      
                      // Add a parameter that prevents Universal Link detection (only once)
                      final modifiedUrl = url.contains('?') 
                          ? '$url&_webview=1&noapp=1'
                          : '$url?_webview=1&noapp=1';
                      
                      // Load the modified URL after canceling the original navigation
                      Future.microtask(() async {
                        try {
                          await controller.loadUrl(
                            urlRequest: URLRequest(
                              url: WebUri(modifiedUrl),
                              headers: {
                                'User-Agent': userAgent,
                                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                              },
                            ),
                          );
                        } catch (e) {
                          print('ProfileWebView - Error loading modified URL: $e');
                        }
                      });
                      
                      return NavigationActionPolicy.CANCEL;
                    }
                    
                    // If social media URL already has our parameters, allow it
                    if (isSocialMediaUrl && 
                        (url.contains('_webview=1') || url.contains('noapp=1'))) {
                      print('ProfileWebView - Allowing social media URL with prevention parameters: $url');
                      return NavigationActionPolicy.ALLOW;
                    }
                    
                    // Only allow social media web domains
                    final allowedDomains = [
                      'twitter.com', 'x.com',
                      'instagram.com',
                      'tiktok.com',
                      'pinterest.com',
                      'reddit.com',
                      'snapchat.com',
                      'youtube.com', 'youtu.be',
                      'google.com'
                    ];
                    
                    bool isAllowed = false;
                    for (var domain in allowedDomains) {
                      if (url.contains(domain)) {
                        isAllowed = true;
                        break;
                      }
                    }
                    
                    if (isAllowed) {
                      print('ProfileWebView - Allowing navigation: $url');
                      return NavigationActionPolicy.ALLOW;
                    }
                    
                    // Block everything else
                    print('ProfileWebView - BLOCKING navigation (not allowed domain): $url');
                    return NavigationActionPolicy.CANCEL;
                  },
                  onReceivedError: (controller, request, error) {
                    print('ProfileWebView - Received Error: ${error.description} for ${request.url}');
                  },
                ),
                if (isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onOkPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('OK'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isValidProfileUrl(String url) {
    final platform = widget.platform.toLowerCase();
    if (platform == 'twitter') {
      return (url.contains('twitter.com') || url.contains('x.com')) &&
          !url.contains('google.com/search');
    }
    if (platform == 'youtube') {
      return url.contains('youtube.com') && !url.contains('google.com/search');
    }
    if (platform == 'facebook') {
    return url.contains('facebook.com') && !url.contains('google.com/search');
  }
    return url.contains('$platform.com') && !url.contains('google.com/search');
  }

  void _onOkPressed() async {
    final url = currentUrl;

    if (url != null && _isValidProfileUrl(url)) {
      _showAddFriendDialog(url);
    } else {
      _showErrorSnackBar(
          'Please select a valid ${widget.platform} profile link');
    }
  }

  void _showAddFriendDialog(String profileUrl) {
    final nameController = TextEditingController();

    String extractedName =
        _extractNameFromUrl(profileUrl) ?? widget.searchQuery;
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
                child: const Icon(
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
                  'URL: ${profileUrl.length > 50 ? '${profileUrl.substring(0, 50)}...' : profileUrl}',
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
                  _addFriendToController(
                      nameController.text.trim(), profileUrl);
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

  void _addFriendToController(String friendName, String profileUrl) {
    final platform = widget.platform.toLowerCase();

    try {
      switch (platform) {
        case 'facebook':
          final controller = Get.find<FaceBookController>();
          controller.addFriendToCategory(
              friendName, widget.iconName, profileUrl);
          break;
        case 'youtube':
          final controller = Get.find<YouTubeController>();
          controller.addFriendToCategory(
              friendName, widget.iconName, profileUrl);
          break;
        case 'pinterest':
          final controller = Get.find<PinterestController>();
          controller.addFriendToCategory(
              friendName, widget.iconName, profileUrl);
          break;
        case 'reddit':
          final controller = Get.find<RedditController>();
          controller.addFriendToCategory(
              friendName, widget.iconName, profileUrl);
          break;
        case 'snapchat':
          final controller = Get.find<SnapchatController>();
          controller.addFriendToCategory(
              friendName, widget.iconName, profileUrl);
          break;
        case 'tiktok':
          final controller = Get.find<TikTokController>();
          controller.addFriendToCategory(
              friendName, widget.iconName, profileUrl);
          break;
        case 'instagram':
          final controller = Get.find<InstagramController>();
          controller.addFriendToCategory(
              friendName, widget.iconName, profileUrl);
          break;
        case 'twitter':
          final controller = Get.find<TwitterController>();
          controller.addFriendToCategory(
              friendName, widget.iconName, profileUrl);
          break;
        default:
          _showErrorSnackBar('Unknown platform: $platform');
          return;
      }

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

      Navigator.of(context).pop();
    } catch (e) {
      _showErrorSnackBar('Error adding friend: $e');
    }
  }

  String? _extractNameFromUrl(String url) {
    final platform = widget.platform.toLowerCase();

    switch (platform) {
      case 'facebook':
        if (url.contains('facebook.com/')) {
          String path = url.split('facebook.com/')[1];
          if (path.isNotEmpty) {
            String username = path.split('?')[0].split('/')[0];
            if (username != 'profile.php' && username != 'pages') {
              return username.replaceAll('-', ' ').replaceAll('_', ' ');
            }
          }
        }
        break;
      case 'twitter':
        if (url.contains('twitter.com/') || url.contains('x.com/')) {
          String domain =
              url.contains('twitter.com/') ? 'twitter.com/' : 'x.com/';
          String path = url.split(domain)[1];
          if (path.isNotEmpty) {
            String username = path.split('?')[0].split('/')[0];
            return username.replaceAll('-', ' ').replaceAll('_', ' ');
          }
        }
        break;
      case 'instagram':
        if (url.contains('instagram.com/')) {
          String path = url.split('instagram.com/')[1];
          if (path.isNotEmpty) {
            String username = path.split('?')[0].split('/')[0];
            return username.replaceAll('-', ' ').replaceAll('_', ' ');
          }
        }
        break;
      case 'youtube':
        if (url.contains('youtube.com/')) {
          String path = url.split('youtube.com/')[1];
          if (path.isNotEmpty) {
            String username = path.split('?')[0].split('/')[0];
            return username.replaceAll('-', ' ').replaceAll('_', ' ');
          }
        }
        break;
    }

    return null;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
  }
}
