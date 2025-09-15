import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  late final WebViewController _controller;
  bool isLoading = true;
  String? currentUrl;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) async {
            setState(() {
              isLoading = false;
            });
            currentUrl = await _controller.currentUrl();
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('intent://') ||
                request.url.startsWith('fb://') ||
                request.url.startsWith('snapchat://')) {
              _handleDeepLink(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..setBackgroundColor(Colors.white)
      ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 10; Mobile; rv:84.0) Gecko/84.0 Firefox/84.0');

    _loadInitialUrl();
  }

  void _handleDeepLink(String url) {
    if (url.startsWith('intent://')) {
      try {
        final fallbackUrl = _extractFallbackUrl(url);
        if (fallbackUrl != null) {
          _controller.loadRequest(Uri.parse(fallbackUrl));
        } else {
          print('Cannot handle this link in WebView');
        }
      } catch (e) {
        print('Error processing link');
      }
    } else {
      print('Cannot handle this link in WebView');
    }
  }

  String? _extractFallbackUrl(String intentUrl) {
    if (intentUrl.contains('browser_fallback_url=')) {
      final startIndex = intentUrl.indexOf('browser_fallback_url=') +
          'browser_fallback_url='.length;
      final endIndex = intentUrl.indexOf('&', startIndex);
      if (endIndex != -1) {
        return Uri.decodeComponent(intentUrl.substring(startIndex, endIndex));
      } else {
        return Uri.decodeComponent(intentUrl.substring(startIndex));
      }
    }
    return null;
  }

  void _loadInitialUrl() {
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

      final googleSearchUrl =
          'https://www.google.com/search?q=${Uri.encodeComponent(query)}';
      _controller.loadRequest(Uri.parse(googleSearchUrl));
    } else {
      final platformUrl = 'https://$platform.com';
      _controller.loadRequest(Uri.parse(platformUrl));
    }
  }

  bool _isValidProfileUrl(String url) {
    final platform = widget.platform.toLowerCase();
    if (platform == 'twitter') {
      return _isValidTwitterUrl(url);
    }
    if (platform == 'youtube') {
      return _isValidYouTubeUrl(url);
    }
    if (platform == 'facebook') {
      return _isValidFacebookUrl(url);
    }
    return _isValidGeneralPlatformUrl(url, platform);
  }

  bool _isValidFacebookUrl(String url) {
    return url.contains('facebook.com') && !url.contains('google.com/search');
  }

  bool _isValidTwitterUrl(String url) {
    return (url.contains('twitter.com') || url.contains('x.com')) &&
        !url.contains('google.com/search');
  }

  bool _isValidYouTubeUrl(String url) {
    return url.contains('youtube.com') && !url.contains('google.com/search');
  }

  bool _isValidGeneralPlatformUrl(String url, String platform) {
    return url.contains('$platform.com') && !url.contains('google.com/search');
  }

  void _onOkPressed() async {
    final url = await _controller.currentUrl();

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
                  Navigator.of(context).pop(); // Close the dialog
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

  @override
  Widget build(BuildContext context) {
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
                WebViewWidget(controller: _controller),
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
}
