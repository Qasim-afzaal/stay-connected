import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

import 'package:stay_connected/Platform/instagram/instagram_controller.dart';
import 'package:stay_connected/Platform/instagram/instagram_search_dialog.dart';

class InstagramIconScreen extends StatelessWidget {
  final String iconName;
  final String platformName;

  const InstagramIconScreen({
    super.key,
    required this.iconName,
    required this.platformName,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InstagramController>(
      builder: (controller) {
        final categoryFriends = controller.icons
            .where((icon) =>
                icon['category'] == iconName &&
                icon['profileUrl'] != null &&
                icon['profileUrl']!.isNotEmpty)
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(iconName),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/img_instagram.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: categoryFriends.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tap the + button to search people',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      itemCount: categoryFriends.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      itemBuilder: (context, index) {
                        final friend = categoryFriends[index];
                        return GestureDetector(
                          onTap: () {
                            // Open the friend's profile in WebView
                            if (friend['profileUrl'] != null) {
                              Get.to(() => _FriendProfileWebView(
                                    profileUrl: friend['profileUrl']!,
                                    friendName: friend['name'] ?? 'Unknown',
                                  ));
                            }
                          },
                          onLongPress: () {
                            // Show delete dialog on long press
                            _showDeleteDialog(
                                context, friend['name'] ?? 'Unknown', index);
                          },
                          child: Stack(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    child: Image.asset(
                                      'assets/images/img_instagram.png',
                                      width: 50,
                                      height: 50,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/images/img_insta.png',
                                          scale: 0.1,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Icon(
                                              Icons.person,
                                              size: 50,
                                              color: Colors.purple.shade700,
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: Text(
                                      friend['name'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showSearchDialog(context),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
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
      },
    );
  }

  void _showSearchDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return InstagramSearchDialog(
          iconName: iconName,
          platformName: platformName,
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String friendName, int index) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CupertinoIcons.delete,
                  color: CupertinoColors.systemRed,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Delete Friend',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              'Are you sure you want to delete $friendName from your $iconName list?',
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey,
              ),
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
              onPressed: () async {
                final controller = Get.find<InstagramController>();

                final categoryFriends = controller.icons
                    .where((icon) =>
                        icon['category'] == iconName &&
                        icon['profileUrl'] != null &&
                        icon['profileUrl']!.isNotEmpty)
                    .toList();

                if (index < categoryFriends.length) {
                  final friendToDelete = categoryFriends[index];
                  controller.icons.removeWhere((icon) =>
                      icon['name'] == friendToDelete['name'] &&
                      icon['category'] == friendToDelete['category'] &&
                      icon['profileUrl'] == friendToDelete['profileUrl']);

                  await controller.saveToPrefs();
                  controller.update();
                }

                Navigator.of(context).pop();
                Get.snackbar(
                  'Friend Deleted',
                  '$friendName has been removed from your $iconName list',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                  backgroundColor: Colors.red.shade100,
                  colorText: Colors.red.shade800,
                );
              },
              isDestructiveAction: true,
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: CupertinoColors.systemRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FriendProfileWebView extends StatefulWidget {
  final String profileUrl;
  final String friendName;

  const _FriendProfileWebView({
    required this.profileUrl,
    required this.friendName,
  });

  @override
  State<_FriendProfileWebView> createState() => _FriendProfileWebViewState();
}

class _FriendProfileWebViewState extends State<_FriendProfileWebView> {
  bool isLoading = true;
  bool isBlocked = false;

  static const String userAgent =
      'Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1 Mobile/15E148 Safari/604.1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.friendName),
        centerTitle: true,
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(widget.profileUrl),
              headers: {
                'Referer': 'https://www.instagram.com/',
                'Accept-Language': 'en-US,en;q=0.9',
              },
            ),
            initialSettings: InAppWebViewSettings(
              userAgent: userAgent,
              javaScriptEnabled: true,
              useShouldOverrideUrlLoading: true,
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
            ),
            onWebViewCreated: (controller) {},
            onLoadStart: (controller, url) {
              setState(() {
                isLoading = true;
                isBlocked = false;
              });
            },
            onLoadStop: (controller, url) async {
              setState(() {
                isLoading = false;
              });
              String? title = await controller.getTitle();
              if (title != null &&
                  (title.toLowerCase().contains('not supported') ||
                      title.toLowerCase().contains('browser not supported'))) {
                setState(() {
                  isBlocked = true;
                });
              }
              if (url != null &&
                  url.toString().contains('browser_not_supported')) {
                setState(() {
                  isBlocked = true;
                });
              }
            },
            onLoadError: (controller, url, code, message) {
              setState(() {
                isLoading = false;
                isBlocked = true;
              });
            },
            onReceivedHttpError: (controller, url, response) {
              setState(() {
                isBlocked = true;
              });
            },
          ),
          if (isLoading) const Center(child: CircularProgressIndicator()),
          if (isBlocked)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.block, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Instagram blocks embedded browsers for security.',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
