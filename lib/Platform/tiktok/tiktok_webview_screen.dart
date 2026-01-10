import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:stay_connected/Platform/tiktok/tiktok_controller.dart';

class TikTokWebviewScreen extends StatefulWidget {
  final String searchQuery;
  final String iconName;
  final String platformName;

  const TikTokWebviewScreen({
    super.key,
    required this.searchQuery,
    required this.iconName,
    required this.platformName,
  });

  @override
  State<TikTokWebviewScreen> createState() => _TikTokWebviewScreenState();
}

class _TikTokWebviewScreenState extends State<TikTokWebviewScreen> {
  InAppWebViewController? webViewController;
  bool isLoading = true;
  String? currentUrl;
  int loadingProgress = 0;

  String _getInitialUrl() {
    String query = widget.searchQuery;
    if (query.isNotEmpty) {
      query = '$query site:tiktok.com';
    }
    return 'https://www.google.com/search?q=${Uri.encodeComponent(query)}';
  }

  bool _isOnGoogleSearch() {
    final url = currentUrl?.toLowerCase() ?? '';
    return url.contains('google.com') || url.contains('googleapis.com');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final isDark = brightness == Brightness.dark;
    
    String userAgent = Platform.isIOS
        ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1'
        : 'Mozilla/5.0 (Linux; Android 10; SM-G975F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.iconName),
        centerTitle: true,
        backgroundColor: isDark ? (theme.appBarTheme.backgroundColor ?? Colors.black) : Colors.white,
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
              
              // Register JavaScript handler for video capture
              controller.addJavaScriptHandler(
                handlerName: 'TikTokVideoCapture',
                callback: (args) async {
                  if (args.isNotEmpty) {
                    String videoUrl = args[0].toString();
                    if (videoUrl.isNotEmpty && videoUrl.startsWith('http')) {
                      // Clean the URL: decode HTML entities and remove query parameters
                      videoUrl = videoUrl
                          .replaceAll('&amp;', '&')
                          .replaceAll('&amp;amp;', '&')
                          .replaceAll('&amp;amp;amp;', '&');
                      
                      // Remove all query parameters (everything after ?)
                      if (videoUrl.contains('?')) {
                        videoUrl = videoUrl.split('?')[0];
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
                      if (videoUrl != cleanCurrentUrl && videoUrl.contains('/video/')) {
                        print('TikTok WebView - Captured video URL: $videoUrl');
                        Future.microtask(() {
                          controller.loadUrl(urlRequest: URLRequest(url: WebUri(videoUrl)));
                        });
                      } else {
                        print('TikTok WebView - Ignoring duplicate URL: $videoUrl');
                      }
                    }
                  }
                },
              );
              
              // Inject dark theme CSS at document start if dark mode is enabled
              if (Theme.of(context).brightness == Brightness.dark) {
                controller.addUserScript(
                  userScript: UserScript(
                    source: '''
                      (function() {
                        const style = document.createElement('style');
                        style.id = 'dark-theme-style';
                        style.textContent = `
                          :root {
                            color-scheme: dark;
                          }
                          html {
                            background-color: #000000 !important;
                            filter: invert(1) hue-rotate(180deg) !important;
                          }
                          img, video, iframe, embed, object, svg, canvas, [style*="background-image"] {
                            filter: invert(1) hue-rotate(180deg) !important;
                          }
                          body {
                            background-color: #000000 !important;
                            color: #ffffff !important;
                          }
                          /* Apply dark theme to common elements */
                          div, section, article, main, header, footer, nav, aside {
                            background-color: transparent !important;
                          }
                          /* Preserve media colors - re-invert images and videos */
                          img[src*=".jpg"], img[src*=".jpeg"], img[src*=".png"], img[src*=".gif"],
                          img[src*=".webp"], video, iframe[src*="youtube"], iframe[src*="vimeo"],
                          img[src*="tiktok"], video[src*="tiktok"] {
                            filter: invert(1) hue-rotate(180deg) !important;
                          }
                        `;
                        if (document.head) {
                          document.head.appendChild(style);
                        } else {
                          document.addEventListener('DOMContentLoaded', function() {
                            if (document.head) {
                              document.head.appendChild(style);
                            }
                          });
                        }
                      })();
                    ''',
                    injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                  ),
                );
              }
              
              // Inject blocking and video capture script at document start
              controller.addUserScript(
                userScript: UserScript(
                  source: '''
                    (function() {
                      if (window.tiktokBlockingLoaded) return;
                      window.tiktokBlockingLoaded = true;
                      
                      // Allow normal navigation for video/reel/image clicks - just ensure URLs have _webview=1&noapp=1
                      function ensureWebViewParams(e) {
                        try {
                          let target = e.target;
                          let depth = 0;
                          
                          while (target && target !== document && depth < 10) {
                            if (target.tagName === 'A' && target.href) {
                              const href = target.href;
                              // For TikTok video links, ensure they have webview params
                              if (href.includes('tiktok.com') && href.includes('/video/') && !href.includes('v16') && !href.includes('v19') && !href.includes('v20') && !href.includes('cdn')) {
                                if (!href.includes('_webview=1') || !href.includes('noapp=1')) {
                                  // Add params if missing
                                  const separator = href.includes('?') ? '&' : '?';
                                  target.href = href + separator + '_webview=1&noapp=1';
                                }
                                // Allow normal navigation - don't prevent default
                                return;
                              }
                            }
                            target = target.parentElement;
                            depth++;
                          }
                        } catch(err) {
                          console.log('TikTok - Error ensuring webview params:', err);
                        }
                      }
                              
                              // Check data attributes for video URLs
                              if (element.attributes) {
                                for (let i = 0; i < element.attributes.length; i++) {
                                  const attr = element.attributes[i];
                                  const attrName = attr.name.toLowerCase();
                                  const attrValue = attr.value;
                                  
                                  // Check data-href, data-url, data-link, etc.
                                  if ((attrName.includes('href') || attrName.includes('url') || attrName.includes('link')) && attrValue) {
                                    if (attrValue.includes('tiktok.com') && attrValue.includes('/video/') && !attrValue.includes('v16') && !attrValue.includes('v19') && !attrValue.includes('v20') && !attrValue.includes('cdn')) {
                                      const videoMatch = attrValue.match(/https?:\\/\\/(www\\.)?tiktok\\.com\\/@[^\\/]+\\/video\\/[^\\s"']+/);
                                      if (videoMatch) {
                                        let videoUrl = videoMatch[0];
                                        if (!videoUrl.startsWith('http')) {
                                          videoUrl = 'https://' + videoUrl;
                                        }
                                        if (!videoUrl.includes('www.')) {
                                          videoUrl = videoUrl.replace('https://tiktok.com', 'https://www.tiktok.com');
                                        }
                                        if (videoUrl.includes('?')) {
                                          videoUrl = videoUrl.split('?')[0];
                                        }
                                        videoUrl = videoUrl.replace(/&amp;/g, '&').replace(/&amp;amp;/g, '&');
                                        const currentUrl = window.location.href.split('?')[0].replace(/&amp;/g, '&');
                                        if (videoUrl !== currentUrl && videoUrl.includes('/video/')) {
                                          console.log('TikTok - Capturing video URL from data attribute:', videoUrl);
                                          if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                                            e.preventDefault();
                                            e.stopPropagation();
                                            e.stopImmediatePropagation();
                                            window.flutter_inappwebview.callHandler('TikTokVideoCapture', videoUrl).catch(function(err) {
                                              console.error('TikTok - Error calling handler:', err);
                                            });
                                            return false;
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                              
                              // Check for link in parent elements (only www.tiktok.com or tiktok.com, not CDN URLs)
                              const linkElement = element.closest('a');
                              if (linkElement && linkElement.href) {
                                const href = linkElement.href;
                                // Only capture URLs from www.tiktok.com or tiktok.com (not CDN like v16-webapp-prime.tiktok.com)
                                if ((href.includes('www.tiktok.com') || (href.includes('tiktok.com') && !href.includes('v16') && !href.includes('v19') && !href.includes('v20') && !href.includes('cdn'))) && href.includes('/video/')) {
                                  const videoMatch = href.match(/https?:\\/\\/(www\\.)?tiktok\\.com\\/@[^\\/]+\\/video\\/[^\\s"']+/);
                                  if (videoMatch) {
                                    let videoUrl = videoMatch[0];
                                    // Ensure it's a full URL
                                    if (!videoUrl.startsWith('http')) {
                                      videoUrl = 'https://' + videoUrl;
                                    }
                                    // Ensure it starts with www.
                                    if (!videoUrl.includes('www.')) {
                                      videoUrl = videoUrl.replace('https://tiktok.com', 'https://www.tiktok.com');
                                    }
                                    // Clean URL: remove query parameters and HTML entities
                                    if (videoUrl.includes('?')) {
                                      videoUrl = videoUrl.split('?')[0];
                                    }
                                    videoUrl = videoUrl.replace(/&amp;/g, '&').replace(/&amp;amp;/g, '&');
                                    // Only capture if different from current URL
                                    const currentUrl = window.location.href.split('?')[0].replace(/&amp;/g, '&');
                                    if (videoUrl !== currentUrl && videoUrl.includes('/video/')) {
                                      if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                                        e.preventDefault();
                                        e.stopPropagation();
                                        e.stopImmediatePropagation();
                                        window.flutter_inappwebview.callHandler('TikTokVideoCapture', videoUrl).catch(function(err) {
                                          console.error('TikTok - Error calling handler:', err);
                                        });
                                        return false;
                                      }
                                    }
                                  }
                                }
                              }
                              
                              // Get all attributes
                              if (element.attributes) {
                                for (let i = 0; i < element.attributes.length; i++) {
                                  const attr = element.attributes[i];
                                  const attrValue = attr.value;
                                  
                                  // Look for video URLs in any attribute (only www.tiktok.com or tiktok.com, not CDN URLs)
                                  if (attrValue && typeof attrValue === 'string') {
                                    // Only capture URLs from www.tiktok.com or tiktok.com (not CDN like v16-webapp-prime.tiktok.com)
                                    if ((attrValue.includes('www.tiktok.com') || (attrValue.includes('tiktok.com') && !attrValue.includes('v16') && !attrValue.includes('v19') && !attrValue.includes('v20') && !attrValue.includes('cdn'))) && attrValue.includes('/video/')) {
                                      const videoMatch = attrValue.match(/https?:\\/\\/(www\\.)?tiktok\\.com\\/@[^\\/]+\\/video\\/[^\\s"']+/);
                                      if (videoMatch) {
                                        let videoUrl = videoMatch[0];
                                        // Ensure it's a full URL
                                        if (!videoUrl.startsWith('http')) {
                                          videoUrl = 'https://' + videoUrl;
                                        }
                                        // Ensure it starts with www.
                                        if (!videoUrl.includes('www.')) {
                                          videoUrl = videoUrl.replace('https://tiktok.com', 'https://www.tiktok.com');
                                        }
                                        if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                                          e.preventDefault();
                                          e.stopPropagation();
                                          e.stopImmediatePropagation();
                                          window.flutter_inappwebview.callHandler('TikTokVideoCapture', videoUrl).catch(function(err) {
                                            console.error('TikTok - Error calling handler:', err);
                                          });
                                          return false;
                                        }
                                      }
                                    }
                                    
                                    // Look for video IDs (long numeric strings) and construct proper URL
                                    const idMatch = attrValue.match(/\\/video\\/(\\d+)/);
                                    if (idMatch) {
                                      const videoId = idMatch[1];
                                      const currentUrl = window.location.href;
                                      const profileMatch = currentUrl.match(/tiktok\\.com\\/(@[^\\/]+)/);
                                      if (profileMatch) {
                                        const videoUrl = 'https://www.tiktok.com/' + profileMatch[1] + '/video/' + videoId;
                                        if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                                          e.preventDefault();
                                          e.stopPropagation();
                                          e.stopImmediatePropagation();
                                          window.flutter_inappwebview.callHandler('TikTokVideoCapture', videoUrl).catch(function(err) {
                                            console.error('TikTok - Error calling handler:', err);
                                          });
                                          return false;
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                              
                              // Check innerHTML for video URLs (only www.tiktok.com or tiktok.com, not CDN URLs)
                              if (element.innerHTML) {
                                // Only capture URLs from www.tiktok.com or tiktok.com (not CDN like v16-webapp-prime.tiktok.com)
                                const htmlMatch = element.innerHTML.match(/https?:\\/\\/(www\\.)?tiktok\\.com\\/@[^\\/]+\\/video\\/[^\\s"']+/);
                                if (htmlMatch) {
                                  let videoUrl = htmlMatch[0];
                                  // Ensure it's a full URL
                                  if (!videoUrl.startsWith('http')) {
                                    videoUrl = 'https://' + videoUrl;
                                  }
                                  // Ensure it starts with www.
                                  if (!videoUrl.includes('www.')) {
                                    videoUrl = videoUrl.replace('https://tiktok.com', 'https://www.tiktok.com');
                                  }
                                  if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                                    e.preventDefault();
                                    e.stopPropagation();
                                    e.stopImmediatePropagation();
                                    window.flutter_inappwebview.callHandler('TikTokVideoCapture', videoUrl).catch(function(err) {
                                      console.error('TikTok - Error calling handler:', err);
                                    });
                                    return false;
                                  }
                                }
                              }
                              
                              element = element.parentElement;
                              searchDepth++;
                            }
                            
                            target = target.parentElement;
                            depth++;
                          }
                        } catch(err) {
                          console.log('TikTok - Error intercepting click:', err);
                        }
                      }
                      
                      // Allow app scheme redirects for TikTok content (videos, reels, images) - let them open in native app
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
                            // Allow all other navigation (including app schemes for TikTok content)
                            return;
                          }
                          target = target.parentElement;
                          depth++;
                        }
                      }, false);
                      
                      // Add listeners to ensure webview params on video links (but allow normal navigation)
                      document.addEventListener('click', ensureWebViewParams, true);
                      document.addEventListener('touchend', ensureWebViewParams, true);
                      
                      // Also ensure params on dynamically added links
                      function addWebViewParamsToLinks() {
                        try {
                          const allLinks = document.querySelectorAll('a[href*="/video/"], a[href*="tiktok.com"]');
                          allLinks.forEach(link => {
                            if (link.href && link.href.includes('tiktok.com') && link.href.includes('/video/') && 
                                !link.href.includes('v16') && !link.href.includes('v19') && !link.href.includes('v20') && !link.href.includes('cdn')) {
                              if (!link.href.includes('_webview=1') || !link.href.includes('noapp=1')) {
                                const separator = link.href.includes('?') ? '&' : '?';
                                link.href = link.href + separator + '_webview=1&noapp=1';
                              }
                            }
                          });
                        } catch(e) {
                          console.log('Error adding webview params to links:', e);
                        }
                      }
                      
                      // Run immediately and after DOM ready
                      if (document.readyState === 'loading') {
                        document.addEventListener('DOMContentLoaded', addWebViewParamsToLinks);
      } else {
                        addWebViewParamsToLinks();
                      }
                      
                      setTimeout(addWebViewParamsToLinks, 500);
                      setTimeout(addWebViewParamsToLinks, 1000);
                      
                      // Override window.open
                      const originalOpen = window.open;
                      window.open = function(url, target, features) {
                        if (url) {
                          const urlLower = url.toLowerCase();
                          if (urlLower.startsWith('tiktok://') ||
                              urlLower.startsWith('snssdk1233://') ||
                              urlLower.startsWith('snssdk1180://') ||
                              urlLower.startsWith('snssdk://') ||
                              urlLower.startsWith('musical://') ||
                              urlLower.startsWith('tt://') ||
                              urlLower.startsWith('intent://') ||
                              urlLower.includes('applink.tiktok.com') ||
                              urlLower.includes('apps.apple.com') ||
                              urlLower.includes('itunes.apple.com')) {
                            return null;
                          }
                        }
                        return originalOpen.call(window, url, target, features);
                      };
                      
                      // Hide "This page isn't available" message, "Open app" buttons, and screen time prompts
                      function hideUnavailableMessage() {
                        try {
                          // Hide the unavailable message container
                          const unavailableSelectors = [
                            '[data-e2e="unavailable-page"]',
                            '[class*="unavailable"]',
                            '[class*="not-available"]',
                            'div:has-text("This page isn\'t available")',
                            'div:has-text("isn\'t available")',
                            'div:has-text("Use the app to discover")',
                          ];
                          
                          unavailableSelectors.forEach(selector => {
                            try {
                              const elements = document.querySelectorAll(selector);
                              elements.forEach(el => {
                                if (el.textContent && (el.textContent.includes("isn't available") || el.textContent.includes("Use the app"))) {
                                  el.style.display = 'none';
                                  el.remove();
                                }
                              });
                            } catch(e) {}
                          });
                          
                          // Hide "Open app" buttons
                          const buttons = document.querySelectorAll('button, a, div[role="button"]');
                          buttons.forEach(btn => {
                            const text = (btn.textContent || btn.innerText || '').toLowerCase();
                            if (text.includes('open app') || text.includes('watch on tiktok') || text.includes('get app')) {
                              btn.style.display = 'none';
                              btn.remove();
                            }
                          });
                          
                          // Hide screen time / break prompts
                          // Hide screen time / break prompts (only modals/overlays, not main content)
                          function hideScreenTimePrompts() {
                            try {
                              // Only target elements that are clearly modals/overlays, not main content
                              const allElements = document.querySelectorAll('[class*="modal"], [class*="overlay"], [class*="dialog"], [class*="popup"], [data-e2e*="modal"]');
                              allElements.forEach(el => {
                                const text = (el.textContent || el.innerText || '').toLowerCase();
                                // Only hide if it's clearly a screen time prompt (has specific text AND is a modal/overlay)
                                if ((text.includes('schedule a break') || 
                                    text.includes('take a break') ||
                                    text.includes('screen time') ||
                                    text.includes('get reminded to take a break') ||
                                    text.includes('select custom time') ||
                                    (text.includes('snooze') && text.includes('min'))) &&
                                    !text.includes('video') && 
                                    !text.includes('@') &&
                                    !el.querySelector('video') &&
                                    !el.querySelector('[class*="video"]')) {
                                  // Check if it's a modal/overlay
                                  const computedStyle = window.getComputedStyle(el);
                                  if (computedStyle.position === 'fixed' || 
                                      computedStyle.position === 'absolute' ||
                                      computedStyle.zIndex > 1000) {
                                    // Try to find and click "OK" or dismiss button first
                                    const buttons = el.querySelectorAll('button, a, div[role="button"]');
                                    buttons.forEach(btn => {
                                      const btnText = (btn.textContent || btn.innerText || '').toLowerCase().trim();
                                      if (btnText === 'ok' || btnText === 'dismiss' || btnText === 'close' || btnText === 'cancel') {
                                        try {
                                          btn.click();
                                        } catch(e) {}
                                      }
                                    });
                                    el.style.display = 'none';
                                    el.remove();
                                  }
                                }
                              });
                            } catch(e) {
                              console.log('Error hiding screen time prompts:', e);
                            }
                          }
                          
                          hideScreenTimePrompts();
                          
                          // Remove app download prompts (but be very specific - only remove actual download prompts, not main content)
                          const appPrompts = document.querySelectorAll('[class*="download-button"], [class*="app-download"], [class*="get-app"], [id*="download-button"], [id*="app-download"]');
                          appPrompts.forEach(el => {
                            const text = (el.textContent || el.innerText || '').toLowerCase();
                            // Only remove if it's clearly a download prompt, not main content
                            if ((text.includes('download app') || 
                                text.includes('get app') || 
                                text.includes('install app') ||
                                text.includes('open in app')) &&
                                !text.includes('video') &&
                                !text.includes('@') &&
                                !el.querySelector('video') &&
                                !el.closest('[class*="video"]') &&
                                !el.closest('[class*="content"]')) {
                              el.style.display = 'none';
                              el.remove();
                            }
                          });
                        } catch(e) {
                          console.log('Error hiding unavailable message:', e);
                        }
                      }
                      
                      // Run immediately and on DOM ready
                      if (document.readyState === 'loading') {
                        document.addEventListener('DOMContentLoaded', hideUnavailableMessage);
                      } else {
                        hideUnavailableMessage();
                      }
                      
                      // Also run after a delay to catch dynamically loaded content
                      setTimeout(hideUnavailableMessage, 500);
                      setTimeout(hideUnavailableMessage, 1000);
                      setTimeout(hideUnavailableMessage, 2000);
                      setTimeout(hideScreenTimePrompts, 500);
                      setTimeout(hideScreenTimePrompts, 1000);
                      setTimeout(hideScreenTimePrompts, 2000);
                      
                      // Watch for dynamically added elements
                      const observer = new MutationObserver(function(mutations) {
                        hideUnavailableMessage();
                        hideScreenTimePrompts();
                      });
                      
                      if (document.body) {
                        observer.observe(document.body, {
                          childList: true,
                          subtree: true
                        });
                      } else {
                        document.addEventListener('DOMContentLoaded', function() {
                          if (document.body) {
                            observer.observe(document.body, {
                              childList: true,
                              subtree: true
                            });
                          }
                        });
                      }
                    })();
                  ''',
                  injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                ),
              );
            },
            onLoadStart: (controller, url) {
            print('TikTok WebView - Page Started: $url');

              if (url?.toString().startsWith('tiktok://') ?? false) {
              print('TikTok WebView - Detected TikTok app redirect, ignoring');
              return;
            }

            if (mounted) {
              setState(() {
                isLoading = true;
                  currentUrl = url?.toString();
                loadingProgress = 0;
                });
              }
              
              // Inject blocking and video capture script early
              controller.evaluateJavascript(source: '''
                (function() {
                  // Intercept video/image thumbnail clicks and capture URLs
                  function interceptVideoClicks(e) {
                    try {
                      let target = e.target;
                      let depth = 0;
                      
                      while (target && target !== document && depth < 25) {
                        let element = target;
                        let searchDepth = 0;
                        
                        while (element && searchDepth < 15) {
                          if (element.tagName === 'A' && element.href) {
                            const href = element.href;
                            // Only capture URLs from www.tiktok.com or tiktok.com (not CDN like v16-webapp-prime.tiktok.com)
                            if ((href.includes('www.tiktok.com') || (href.includes('tiktok.com') && !href.includes('v16') && !href.includes('v19') && !href.includes('v20') && !href.includes('cdn'))) && href.includes('/video/')) {
                              const videoMatch = href.match(/https?:\\/\\/(www\\.)?tiktok\\.com\\/@[^\\/]+\\/video\\/[^\\s"']+/);
                              if (videoMatch) {
                                let videoUrl = videoMatch[0];
                                if (!videoUrl.startsWith('http')) {
                                  videoUrl = 'https://' + videoUrl;
                                }
                                if (!videoUrl.includes('www.')) {
                                  videoUrl = videoUrl.replace('https://tiktok.com', 'https://www.tiktok.com');
                                }
                                // Clean URL: remove query parameters and HTML entities
                                if (videoUrl.includes('?')) {
                                  videoUrl = videoUrl.split('?')[0];
                                }
                                videoUrl = videoUrl.replace(/&amp;/g, '&').replace(/&amp;amp;/g, '&');
                                // Only capture if different from current URL
                                const currentUrl = window.location.href.split('?')[0].replace(/&amp;/g, '&');
                                if (videoUrl !== currentUrl && videoUrl.includes('/video/')) {
                                  console.log('TikTok - Capturing video URL:', videoUrl);
                                  if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                                    e.preventDefault();
                                    e.stopPropagation();
                                    e.stopImmediatePropagation();
                                    window.flutter_inappwebview.callHandler('TikTokVideoCapture', videoUrl).catch(function(err) {
                                      console.error('TikTok - Error calling handler:', err);
                                      // If handler fails, allow normal navigation
                                      window.location.href = videoUrl;
                                    });
                                    return false;
                                  } else {
                                    // Handler not available, allow normal navigation
                                    return true;
                                  }
                                }
                              }
                            }
                          }
                          
                          const linkElement = element.closest('a');
                          if (linkElement && linkElement.href) {
                            const href = linkElement.href;
                            // Only capture URLs from www.tiktok.com or tiktok.com (not CDN like v16-webapp-prime.tiktok.com)
                            if ((href.includes('www.tiktok.com') || (href.includes('tiktok.com') && !href.includes('v16') && !href.includes('v19') && !href.includes('v20') && !href.includes('cdn'))) && href.includes('/video/')) {
                              const videoMatch = href.match(/https?:\\/\\/(www\\.)?tiktok\\.com\\/@[^\\/]+\\/video\\/[^\\s"']+/);
                              if (videoMatch) {
                                let videoUrl = videoMatch[0];
                                if (!videoUrl.startsWith('http')) {
                                  videoUrl = 'https://' + videoUrl;
                                }
                                if (!videoUrl.includes('www.')) {
                                  videoUrl = videoUrl.replace('https://tiktok.com', 'https://www.tiktok.com');
                                }
                                // Clean URL: remove query parameters and HTML entities
                                if (videoUrl.includes('?')) {
                                  videoUrl = videoUrl.split('?')[0];
                                }
                                videoUrl = videoUrl.replace(/&amp;/g, '&').replace(/&amp;amp;/g, '&');
                                // Only capture if different from current URL
                                const currentUrl = window.location.href.split('?')[0].replace(/&amp;/g, '&');
                                if (videoUrl !== currentUrl && videoUrl.includes('/video/')) {
                                  console.log('TikTok - Capturing video URL:', videoUrl);
                                  if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                                    e.preventDefault();
                                    e.stopPropagation();
                                    e.stopImmediatePropagation();
                                    window.flutter_inappwebview.callHandler('TikTokVideoCapture', videoUrl).catch(function(err) {
                                      console.error('TikTok - Error calling handler:', err);
                                      // If handler fails, allow normal navigation
                                      window.location.href = videoUrl;
                                    });
                                    return false;
                                  } else {
                                    // Handler not available, allow normal navigation
                                    return true;
                                  }
                                }
                              }
                            }
                          }
                          
                          element = element.parentElement;
                          searchDepth++;
                        }
                        
                        target = target.parentElement;
                        depth++;
                      }
                    } catch(err) {}
                  }
                  
                  document.addEventListener('click', interceptVideoClicks, true);
                  document.addEventListener('touchend', interceptVideoClicks, true);
                  
                  // Block all clicks that would open TikTok app (but allow video links to navigate normally)
                  document.addEventListener('click', function(e) {
                    let target = e.target;
                    let depth = 0;
                    while (target && target !== document && depth < 10) {
                      if (target.tagName === 'A' && target.href) {
                        const href = target.href.toLowerCase();
                        // Allow video links to navigate normally (they should be captured, but allow as fallback)
                        if (href.includes('tiktok.com') && href.includes('/video/') && !href.includes('v16') && !href.includes('v19') && !href.includes('v20') && !href.includes('cdn')) {
                          return; // Let it navigate normally
                        }
                        // Block app schemes
                        if (href.startsWith('tiktok://') ||
                            href.startsWith('snssdk1233://') ||
                            href.startsWith('snssdk1180://') ||
                            href.startsWith('snssdk://') ||
                            href.startsWith('musical://') ||
                            href.startsWith('tt://') ||
                            href.startsWith('intent://') ||
                            href.includes('applink.tiktok.com') ||
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
                  }, false); // Use bubble phase so video capture runs first
                })();
              ''');
            },
            onLoadStop: (controller, url) async {
            print('TikTok WebView - Page Finished: $url');

              if (url?.toString().startsWith('tiktok://') ?? false) {
              print('TikTok WebView - Ignoring app redirect completion');
              return;
            }

            if (mounted) {
              setState(() {
                isLoading = false;
                  currentUrl = url?.toString();
                loadingProgress = 100;
                });
              }
              
              // Inject blocking and video capture script again after page loads
              await controller.evaluateJavascript(source: '''
                (function() {
                  // Intercept video/image thumbnail clicks and capture URLs
                  function interceptVideoClicks(e) {
                    try {
                      let target = e.target;
                      let depth = 0;
                      
                      while (target && target !== document && depth < 25) {
                        let element = target;
                        let searchDepth = 0;
                        
                        while (element && searchDepth < 15) {
                          if (element.tagName === 'A' && element.href) {
                            const href = element.href;
                            // Only capture URLs from www.tiktok.com or tiktok.com (not CDN like v16-webapp-prime.tiktok.com)
                            if ((href.includes('www.tiktok.com') || (href.includes('tiktok.com') && !href.includes('v16') && !href.includes('v19') && !href.includes('v20') && !href.includes('cdn'))) && href.includes('/video/')) {
                              const videoMatch = href.match(/https?:\\/\\/(www\\.)?tiktok\\.com\\/@[^\\/]+\\/video\\/[^\\s"']+/);
                              if (videoMatch) {
                                let videoUrl = videoMatch[0];
                                if (!videoUrl.startsWith('http')) {
                                  videoUrl = 'https://' + videoUrl;
                                }
                                if (!videoUrl.includes('www.')) {
                                  videoUrl = videoUrl.replace('https://tiktok.com', 'https://www.tiktok.com');
                                }
                                // Clean URL: remove query parameters and HTML entities
                                if (videoUrl.includes('?')) {
                                  videoUrl = videoUrl.split('?')[0];
                                }
                                videoUrl = videoUrl.replace(/&amp;/g, '&').replace(/&amp;amp;/g, '&');
                                // Only capture if different from current URL
                                const currentUrl = window.location.href.split('?')[0].replace(/&amp;/g, '&');
                                if (videoUrl !== currentUrl && videoUrl.includes('/video/')) {
                                  console.log('TikTok - Capturing video URL:', videoUrl);
                                  if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                                    e.preventDefault();
                                    e.stopPropagation();
                                    e.stopImmediatePropagation();
                                    window.flutter_inappwebview.callHandler('TikTokVideoCapture', videoUrl).catch(function(err) {
                                      console.error('TikTok - Error calling handler:', err);
                                      // If handler fails, allow normal navigation
                                      window.location.href = videoUrl;
                                    });
                                    return false;
                                  } else {
                                    // Handler not available, allow normal navigation
                                    return true;
                                  }
                                }
                              }
                            }
                          }
                          
                          const linkElement = element.closest('a');
                          if (linkElement && linkElement.href) {
                            const href = linkElement.href;
                            // Only capture URLs from www.tiktok.com or tiktok.com (not CDN like v16-webapp-prime.tiktok.com)
                            if ((href.includes('www.tiktok.com') || (href.includes('tiktok.com') && !href.includes('v16') && !href.includes('v19') && !href.includes('v20') && !href.includes('cdn'))) && href.includes('/video/')) {
                              const videoMatch = href.match(/https?:\\/\\/(www\\.)?tiktok\\.com\\/@[^\\/]+\\/video\\/[^\\s"']+/);
                              if (videoMatch) {
                                let videoUrl = videoMatch[0];
                                if (!videoUrl.startsWith('http')) {
                                  videoUrl = 'https://' + videoUrl;
                                }
                                if (!videoUrl.includes('www.')) {
                                  videoUrl = videoUrl.replace('https://tiktok.com', 'https://www.tiktok.com');
                                }
                                // Clean URL: remove query parameters and HTML entities
                                if (videoUrl.includes('?')) {
                                  videoUrl = videoUrl.split('?')[0];
                                }
                                videoUrl = videoUrl.replace(/&amp;/g, '&').replace(/&amp;amp;/g, '&');
                                // Only capture if different from current URL
                                const currentUrl = window.location.href.split('?')[0].replace(/&amp;/g, '&');
                                if (videoUrl !== currentUrl && videoUrl.includes('/video/')) {
                                  console.log('TikTok - Capturing video URL:', videoUrl);
                                  if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                                    e.preventDefault();
                                    e.stopPropagation();
                                    e.stopImmediatePropagation();
                                    window.flutter_inappwebview.callHandler('TikTokVideoCapture', videoUrl).catch(function(err) {
                                      console.error('TikTok - Error calling handler:', err);
                                      // If handler fails, allow normal navigation
                                      window.location.href = videoUrl;
                                    });
                                    return false;
                                  } else {
                                    // Handler not available, allow normal navigation
                                    return true;
                                  }
                                }
                              }
                            }
                          }
                          
                          element = element.parentElement;
                          searchDepth++;
                        }
                        
                        target = target.parentElement;
                        depth++;
                      }
                    } catch(err) {}
                  }
                  
                  document.addEventListener('click', interceptVideoClicks, true);
                  document.addEventListener('touchend', interceptVideoClicks, true);
                  
                  // Block all clicks that would open TikTok app (but allow video links to navigate normally)
                  document.addEventListener('click', function(e) {
                    let target = e.target;
                    let depth = 0;
                    while (target && target !== document && depth < 10) {
                      if (target.tagName === 'A' && target.href) {
                        const href = target.href.toLowerCase();
                        // Allow video links to navigate normally (they should be captured, but allow as fallback)
                        if (href.includes('tiktok.com') && href.includes('/video/') && !href.includes('v16') && !href.includes('v19') && !href.includes('v20') && !href.includes('cdn')) {
                          return; // Let it navigate normally
                        }
                        // Block app schemes
                        if (href.startsWith('tiktok://') ||
                            href.startsWith('snssdk1233://') ||
                            href.startsWith('snssdk1180://') ||
                            href.startsWith('snssdk://') ||
                            href.startsWith('musical://') ||
                            href.startsWith('tt://') ||
                            href.startsWith('intent://') ||
                            href.includes('applink.tiktok.com') ||
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
                  }, false); // Use bubble phase so video capture runs first
                  
                  // Override window.open
                  const originalOpen = window.open;
                  window.open = function(url, target, features) {
                    if (url) {
                      const urlLower = url.toLowerCase();
                      if (urlLower.startsWith('tiktok://') ||
                          urlLower.startsWith('snssdk1233://') ||
                          urlLower.startsWith('snssdk1180://') ||
                          urlLower.startsWith('snssdk://') ||
                          urlLower.startsWith('musical://') ||
                          urlLower.startsWith('tt://') ||
                          urlLower.startsWith('intent://') ||
                          urlLower.includes('applink.tiktok.com') ||
                          urlLower.includes('apps.apple.com') ||
                          urlLower.includes('itunes.apple.com')) {
                        return null;
                      }
                    }
                    return originalOpen.call(window, url, target, features);
                  };
                  
                  // Hide "This page isn't available" message, "Open app" buttons, and screen time prompts
                  function hideUnavailableMessage() {
                    try {
                      // Hide the unavailable message container
                      const unavailableSelectors = [
                        '[data-e2e="unavailable-page"]',
                        '[class*="unavailable"]',
                        '[class*="not-available"]',
                      ];
                      
                      unavailableSelectors.forEach(selector => {
                        try {
                          const elements = document.querySelectorAll(selector);
                          elements.forEach(el => {
                            if (el.textContent && (el.textContent.includes("isn't available") || el.textContent.includes("Use the app"))) {
                              el.style.display = 'none';
                              el.remove();
                            }
                          });
                        } catch(e) {}
                      });
                      
                      // Hide "Open app" buttons
                      const buttons = document.querySelectorAll('button, a, div[role="button"]');
                      buttons.forEach(btn => {
                        const text = (btn.textContent || btn.innerText || '').toLowerCase();
                        if (text.includes('open app') || text.includes('watch on tiktok') || text.includes('get app')) {
                          btn.style.display = 'none';
                          btn.remove();
                        }
                      });
                      
                      // Hide screen time / break prompts and auto-dismiss them (but be careful not to hide main content)
                      function hideScreenTimePrompts() {
                        try {
                          // Only target elements that are clearly modals/overlays, not main content
                          const allElements = document.querySelectorAll('[class*="modal"], [class*="overlay"], [class*="dialog"], [class*="popup"], [data-e2e*="modal"]');
                          allElements.forEach(el => {
                            const text = (el.textContent || el.innerText || '').toLowerCase();
                            // Only hide if it's clearly a screen time prompt (has specific text AND is a modal/overlay)
                            if ((text.includes('schedule a break') || 
                                text.includes('take a break') ||
                                text.includes('screen time') ||
                                text.includes('get reminded to take a break') ||
                                text.includes('select custom time') ||
                                (text.includes('snooze') && text.includes('min'))) &&
                                !text.includes('video') && 
                                !text.includes('@') &&
                                !el.querySelector('video') &&
                                !el.querySelector('[class*="video"]')) {
                              // Check if it's a modal/overlay
                              const computedStyle = window.getComputedStyle(el);
                              if (computedStyle.position === 'fixed' || 
                                  computedStyle.position === 'absolute' ||
                                  computedStyle.zIndex > 1000) {
                                // Try to find and click "OK" or dismiss button first
                                const buttons = el.querySelectorAll('button, a, div[role="button"]');
                                buttons.forEach(btn => {
                                  const btnText = (btn.textContent || btn.innerText || '').toLowerCase().trim();
                                  if (btnText === 'ok' || btnText === 'dismiss' || btnText === 'close' || btnText === 'cancel') {
                                    try {
                                      btn.click();
                                    } catch(e) {}
                                  }
                                });
                                el.style.display = 'none';
                                el.remove();
        }
      }
    });

                          // Also try to click "OK" buttons on screen time prompts (only in modals)
                          const modalButtons = document.querySelectorAll('[class*="modal"] button, [class*="overlay"] button, [class*="dialog"] button');
                          modalButtons.forEach(btn => {
                            const btnText = (btn.textContent || btn.innerText || '').toLowerCase().trim();
                            // Check if button is in a screen time context
                            let parent = btn.parentElement;
                            let depth = 0;
                            while (parent && parent !== document.body && depth < 5) {
                              const parentText = (parent.textContent || parent.innerText || '').toLowerCase();
                              if ((parentText.includes('schedule a break') || parentText.includes('screen time')) &&
                                  !parentText.includes('video') &&
                                  !parent.querySelector('video')) {
                                if (btnText === 'ok' || btnText === 'dismiss') {
                                  try {
                                    btn.click();
                                  } catch(e) {}
                                }
                                break;
                              }
                              parent = parent.parentElement;
                              depth++;
                            }
                          });
                        } catch(e) {
                          console.log('Error hiding screen time prompts:', e);
                        }
                      }
                      
                      hideScreenTimePrompts();
                      
                      // Remove app download prompts (but be very specific - only remove actual download prompts, not main content)
                      const appPrompts = document.querySelectorAll('[class*="download-button"], [class*="app-download"], [class*="get-app"], [id*="download-button"], [id*="app-download"]');
                      appPrompts.forEach(el => {
                        const text = (el.textContent || el.innerText || '').toLowerCase();
                        // Only remove if it's clearly a download prompt, not main content
                        if ((text.includes('download app') || 
                            text.includes('get app') || 
                            text.includes('install app') ||
                            text.includes('open in app')) &&
                            !text.includes('video') &&
                            !text.includes('@') &&
                            !el.querySelector('video') &&
                            !el.closest('[class*="video"]') &&
                            !el.closest('[class*="content"]')) {
                          el.style.display = 'none';
                          el.remove();
                        }
                      });
                    } catch(e) {
                      console.log('Error hiding unavailable message:', e);
                    }
                  }
                  
                  // Run immediately and on DOM ready
                  if (document.readyState === 'loading') {
                    document.addEventListener('DOMContentLoaded', hideUnavailableMessage);
                  } else {
                    hideUnavailableMessage();
                  }
                  
                  // Also run after delays to catch dynamically loaded content
                  setTimeout(hideUnavailableMessage, 500);
                  setTimeout(hideUnavailableMessage, 1000);
                  setTimeout(hideUnavailableMessage, 2000);
                  
                  // Watch for dynamically added elements
                  const observer = new MutationObserver(function(mutations) {
                    hideUnavailableMessage();
                  });
                  
                  if (document.body) {
                    observer.observe(document.body, {
                      childList: true,
                      subtree: true
                    });
                  } else {
                    document.addEventListener('DOMContentLoaded', function() {
                      if (document.body) {
                        observer.observe(document.body, {
                          childList: true,
                          subtree: true
                        });
      }
    });
  }
                })();
              ''');
            },
            onProgressChanged: (controller, progress) {
              print('TikTok WebView - Loading Progress: $progress%');
              setState(() {
                loadingProgress = progress.toInt();
              });
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final url = navigationAction.request.url?.toString() ?? '';
              final urlLower = url.toLowerCase();
              final isMainFrame = navigationAction.targetFrame?.isMainFrame ?? true;
              
              print('TikTok WebView - Navigation request to: $url (isMainFrame: $isMainFrame)');

              // Block Google OAuth/iframe URLs that cause white screens
              if (urlLower.contains('accounts.google.com') ||
                  urlLower.contains('google.com/gsi/') ||
                  urlLower.contains('google.com/oauth2/')) {
                print('TikTok WebView - Blocking Google OAuth/iframe URL: $url');
                return NavigationActionPolicy.CANCEL;
              }
              
              // Block applink.tiktok.com URLs (Universal Links)
              if (urlLower.contains('applink.tiktok.com')) {
                print('TikTok WebView - Blocking applink URL: $url');
                return NavigationActionPolicy.CANCEL;
              }
              
              // Block URLs with launch_app_store parameter
              if (urlLower.contains('launch_app_store=true')) {
                print('TikTok WebView - Blocking URL with launch_app_store: $url');
                return NavigationActionPolicy.CANCEL;
              }

              // Allow intent:// for TikTok (Android deep links)
              if (url.startsWith('intent://') && urlLower.contains('tiktok')) {
                print('TikTok WebView - Allowing intent:// redirect for TikTok: $url');
                return NavigationActionPolicy.ALLOW;
              }

              // Allow redirect URLs and app schemes for TikTok content (videos, profiles, reels, images)
              // Let them redirect to the native app
              if (urlLower.contains('app-va.tiktokv.com/redirect') || 
                  urlLower.contains('tiktokv.com/redirect') ||
                  urlLower.startsWith('tiktok://') ||
                  urlLower.startsWith('snssdk1233://') ||
                  urlLower.startsWith('snssdk1180://') ||
                  urlLower.startsWith('snssdk://') ||
                  urlLower.startsWith('musical://') ||
                  urlLower.startsWith('tt://')) {
                print('TikTok WebView - Allowing app redirect for TikTok content: $url');
                return NavigationActionPolicy.ALLOW;
              }
              
              // Block only direct app schemes and App Store URLs (not redirect URLs)
              if (urlLower.startsWith('apps.apple.com') ||
                  urlLower.startsWith('itunes.apple.com') ||
                  urlLower.startsWith('itms://') ||
                  urlLower.startsWith('itms-apps://') ||
                  urlLower.startsWith('play.google.com/store') ||
                  urlLower.startsWith('market://')) {
                print('TikTok WebView - Blocking app scheme/App Store URL: $url');
                return NavigationActionPolicy.CANCEL;
              }
              
              // For main frame TikTok URLs only, ensure _webview=1&noapp=1 parameters are present
              // Don't modify iframe URLs or OAuth URLs
              if (isMainFrame &&
                  urlLower.contains('tiktok.com') &&
                  !urlLower.contains('accounts.google.com') &&
                  !urlLower.contains('google.com/gsi/') &&
                  !urlLower.contains('google.com/oauth2/') &&
                  !urlLower.contains('_webview=1') &&
                  !urlLower.contains('noapp=1')) {
                print('TikTok WebView - Modifying URL to prevent Universal Links: $url');
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

  void _showAddFriendDialog() async {
    // Don't show dialog if on Google search page
    if (_isOnGoogleSearch()) {
      Get.snackbar(
        'Error',
        'Please navigate to a TikTok profile page first',
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
        'Please navigate to a TikTok profile page first',
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
        'https://www.tiktok.com/search?q=${Uri.encodeComponent(friendName)}';

    final controller = Get.find<TikTokController>();
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
    if (url.contains('tiktok.com/@')) {
      String path = url.split('tiktok.com/@')[1];
      if (path.isNotEmpty) {
        String username = path.split('?')[0].split('/')[0];
        return username.replaceAll('-', ' ').replaceAll('_', ' ');
      }
    }
    return null;
  }
}
