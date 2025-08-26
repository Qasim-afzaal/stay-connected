import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:stay_connected/Platform/youtube/youtube_controller.dart';

class YouTubeWebviewScreen extends StatefulWidget {
  final String searchQuery;
  final String iconName;
  final String platformName;

  const YouTubeWebviewScreen({
    Key? key,
    required this.searchQuery,
    required this.iconName,
    required this.platformName,
  }) : super(key: key);

  @override
  State<YouTubeWebviewScreen> createState() => _YouTubeWebviewScreenState();
}

class _YouTubeWebviewScreenState extends State<YouTubeWebviewScreen> {
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
    _loaderTimer = Timer(const Duration(seconds: 25), () {
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
    try {
      String? title = await _controller.getTitle();
      String url = currentUrl ?? '';

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
        setState(() {
          isBlocked = true;
          isLoading = false;
          hasError = true;
          errorMessage =
              'YouTube is blocking this browser or showing a captcha.';
        });
      }
    } catch (_) {}
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
    String userAgent = Platform.isIOS
        ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1'
        : 'Mozilla/5.0 (Linux; Android 10; SM-G975F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(userAgent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (url.startsWith('youtube://')) {
              setState(() {
                isNavigatingToApp = true;
              });
              return;
            }

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
            if (url.startsWith('youtube://')) {
              return;
            }

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
            if (request.url.startsWith('youtube://')) {
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
              if (change.url!.startsWith('youtube://')) {
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
            }
          },
          onProgress: (int progress) {
            setState(() {
              loadingProgress = progress;
              lastProgressUpdate = DateTime.now().millisecondsSinceEpoch;
            });

            if (progress >= 85 &&
                isLoading &&
                !hasLoadedSuccessfully &&
                !isNavigatingToApp) {
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

    _fallbackTimer = Timer(const Duration(seconds: 8), () async {
      if (mounted &&
          isLoading &&
          !hasLoadedSuccessfully &&
          !isNavigatingToApp) {
        try {
          String? title = await _controller.getTitle();
          if (title != null && title.isNotEmpty && title != 'Google') {
            setState(() {
              isLoading = false;
              hasLoadedSuccessfully = true;
            });
            _loaderTimer?.cancel();
            _fallbackTimer?.cancel();
            _progressTimer?.cancel();
            await _checkBlockOrCaptcha();
          }
        } catch (_) {}
      }
    });

    Timer(const Duration(seconds: 15), () async {
      if (mounted &&
          isLoading &&
          !hasLoadedSuccessfully &&
          !isNavigatingToApp) {
        try {
          String? title = await _controller.getTitle();
          if (title != null && title.isNotEmpty) {
            setState(() {
              isLoading = false;
              hasLoadedSuccessfully = true;
            });
            _loaderTimer?.cancel();
            _fallbackTimer?.cancel();
            _progressTimer?.cancel();
            await _checkBlockOrCaptcha();
          }
        } catch (_) {}
      }
    });

    Timer(const Duration(seconds: 12), () async {
      if (mounted &&
          isLoading &&
          !hasLoadedSuccessfully &&
          loadingProgress >= 85 &&
          !isNavigatingToApp) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Search: ${widget.searchQuery}'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
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
                      _controller.reload();
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
            SizedBox.expand(child: WebViewWidget(controller: _controller)),
          if (isLoading && !hasError && !isNavigatingToApp)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.8),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/img_youtube.png',
                        width: 50,
                        height: 50,
                        errorBuilder: (context, error, stackTrace) {
                          return CircularProgressIndicator(
                            value: loadingProgress / 100,
                            backgroundColor: Colors.grey[300],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text('Loading YouTube...',
                          style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('$loadingProgress%',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.grey)),
                      if (loadingProgress >= 85) ...[
                        const SizedBox(height: 8),
                        const Text('Almost done...',
                            style: TextStyle(fontSize: 12, color: Colors.red)),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        onPressed: () => _showAddFriendDialog(),
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
    String? actualCurrentUrl;

    try {
      actualCurrentUrl = await _controller.currentUrl();
    } catch (_) {
      actualCurrentUrl = currentUrl;
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
                child: Icon(CupertinoIcons.person_add,
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
        if (username != 'watch' && username != 'playlist') {
          return username.replaceAll('-', ' ').replaceAll('_', ' ');
        }
      }
    }
    return null;
  }
}
