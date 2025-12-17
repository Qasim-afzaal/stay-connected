import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:stay_connected/Platform/snapchat/snapchat_controller.dart';
import 'package:stay_connected/Platform/snapchat/snapchat_search_dialog.dart';

class SnapchatIconScreen extends StatelessWidget {
  final String iconName;
  final String platformName;

  const SnapchatIconScreen({
    super.key,
    required this.iconName,
    required this.platformName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GetBuilder<SnapchatController>(
      builder: (controller) {
        final categoryFriends = controller.icons
            .where((icon) =>
                icon['category'] == iconName &&
                icon['profileUrl'] != null &&
                icon['profileUrl']!.isNotEmpty)
            .toList();

        print('Snapchat - Current category: $iconName');
        print('Snapchat - Total icons: ${controller.icons.length}');
        print('Snapchat - Category friends: ${categoryFriends.length}');
        for (var icon in controller.icons) {
          print(
              'Snapchat - Icon: ${icon['name']}, Category: ${icon['category']}, ProfileUrl: ${icon['profileUrl']}');
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(iconName),
            centerTitle: true,
            backgroundColor: theme.appBarTheme.backgroundColor,
            foregroundColor: theme.appBarTheme.foregroundColor,
            elevation: 0,
          ),
          body: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.black : null,
              image: isDark ? null : DecorationImage(
                image: AssetImage('assets/images/img_group_292.jpg'),
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
                          color: isDark ? Colors.grey[600] : Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tap the + button to search people',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey.shade500,
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
                            if (friend['profileUrl'] != null) {
                              Get.to(() => _FriendProfileWebView(
                                    profileUrl: friend['profileUrl']!,
                                    friendName: friend['name'] ?? 'Unknown',
                                  ));
                            }
                          },
                          onLongPress: () {
                            _showActionDialog(
                                context, friend['name'] ?? 'Unknown', index);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                child: Image.asset(
                                  'assets/images/img_snapchat.png',
                                  scale: 0.1,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.yellow.shade700,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  friend['name'] ?? 'Unknown',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.grey[300] : Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
          // Debug buttons - remove in production
        );
      },
    );
  }

  void _showSearchDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return SnapchatSearchDialog(
          iconName: iconName,
          platformName: platformName,
        );
      },
    );
  }

  void _showActionDialog(BuildContext context, String friendName, int index) {
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
                  CupertinoIcons.person_2,
                  color: CupertinoColors.systemBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Friend Options',
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
              'What would you like to do with $friendName?',
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
              onPressed: () {
                Navigator.of(context).pop();
                _showRenameDialog(context, friendName, index);
              },
              child: const Text(
                'Rename',
                style: TextStyle(
                  color: CupertinoColors.activeBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
                _showMoveDialog(context, friendName, index, iconName);
              },
              child: const Text(
                'Move',
                style: TextStyle(
                  color: CupertinoColors.systemBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
                _showDeleteConfirmationDialog(context, friendName, index);
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
  void _showRenameDialog(BuildContext context, String oldName, int index) {
  final controller = Get.find<SnapchatController>();
  final renameController = TextEditingController(text: oldName);

  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return Material( // ✅ Needed so Cupertino dialog renders properly
        color: Colors.transparent,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // ✅ prevents unnecessary scrolling
              children: [
                const Text(
                  "Rename Friend",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                CupertinoTextField(
                  controller: renameController,
                  autofocus: true,
                  placeholder: "Enter new name",
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Cancel"),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      onPressed: () async {
                        final newName = renameController.text.trim();
                        if (newName.isNotEmpty) {
                          final categoryFriends = controller.icons
                              .where((icon) =>
                                  icon['category'] == iconName &&
                                  icon['profileUrl'] != null &&
                                  icon['profileUrl']!.isNotEmpty)
                              .toList();

                          if (index < categoryFriends.length) {
                            final friendToRename = categoryFriends[index];
                            final originalIndex =
                                controller.icons.indexOf(friendToRename);

                            await controller.renameIcon(originalIndex, newName);
                          }

                          Navigator.of(context).pop();
                          final isDark = Theme.of(context).brightness == Brightness.dark;
                          Get.snackbar(
                            'Friend Renamed',
                            '$oldName has been renamed to $newName',
                            snackPosition: SnackPosition.BOTTOM,
                            duration: const Duration(seconds: 2),
                            backgroundColor: isDark ? Colors.blue[900] : Colors.blue.shade100,
                            colorText: isDark ? Colors.blue[100] : Colors.blue.shade800,
                          );
                        }
                      },
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}


void _showMoveDialog(BuildContext context, String friendName, int index, String iconName) {
  final controller = Get.find<SnapchatController>();

  // Get all available categories including custom ones
  final allCategories = controller.getAvailableCategories();
  
  // Also get categories that have friends (for debugging)
  final categoriesWithFriends = controller.getCategoriesWithFriends();

  print('Snapchat - All Categories: $allCategories');
  print('Snapchat - Categories with Friends: $categoriesWithFriends');
  print('Snapchat - Current category: $iconName');
  print('Snapchat - Total icons in controller: ${controller.icons.length}');
  
  // Debug: Print all icons to see what's stored
  for (var icon in controller.icons) {
    print('Snapchat - Icon: ${icon['name']}, Category: ${icon['category']}, ProfileUrl: ${icon['profileUrl']}');
  }

  if (allCategories.isEmpty) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.snackbar(
      'No Categories Available',
      'There are no categories to move this friend to.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: isDark ? Colors.orange[900] : Colors.orange.shade100,
      colorText: isDark ? Colors.orange[100] : Colors.orange.shade800,
    );
    return;
  }

  int selectedCategoryIndex = 0; // Default first

  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                CupertinoIcons.arrow_right_arrow_left,
                color: CupertinoColors.systemGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Move Friend',
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Move $friendName to which category?',
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: CupertinoPicker(
                  itemExtent: 40,
                  onSelectedItemChanged: (int selectedIndex) {
                    selectedCategoryIndex = selectedIndex;
                  },
                  children: allCategories.map((category) {
                    return Center(
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
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
            onPressed: () async {
              if (selectedCategoryIndex < allCategories.length) {
                final newCategory = allCategories[selectedCategoryIndex];

                final categoryFriends = controller.icons
                    .where((icon) =>
                        icon['category'] == iconName &&
                        icon['profileUrl'] != null &&
                        icon['profileUrl']!.isNotEmpty)
                    .toList();

                if (index < categoryFriends.length) {
                  final friendToMove = categoryFriends[index];
                  await controller.moveFriendToCategory(
                    friendToMove['name']!,
                    friendToMove['category']!,
                    newCategory,
                    friendToMove['profileUrl']!,
                  );
                }

                Navigator.of(context).pop();
                final isDark = Theme.of(context).brightness == Brightness.dark;
                Get.snackbar(
                  'Friend Moved',
                  '$friendName has been moved to $newCategory',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                  backgroundColor: isDark ? Colors.green[900] : Colors.green.shade100,
                  colorText: isDark ? Colors.green[100] : Colors.green.shade800,
                );
              }
            },
            child: const Text(
              'Move',
              style: TextStyle(
                color: CupertinoColors.systemGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    },
  );
}

  void _showDeleteConfirmationDialog(BuildContext context, String friendName, int index) {
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
                final controller = Get.find<SnapchatController>();

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
                final isDark = Theme.of(context).brightness == Brightness.dark;
                Get.snackbar(
                  'Friend Deleted',
                  '$friendName has been removed from your $iconName list',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                  backgroundColor: isDark ? Colors.red[900] : Colors.red.shade100,
                  colorText: isDark ? Colors.red[100] : Colors.red.shade800,
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
  InAppWebViewController? webViewController;
  bool isLoading = true;

  String _getProfileUrl() {
    String url = widget.profileUrl;
    // Add parameters to prevent Universal Links if not already present
    if (!url.contains('_webview=1') && !url.contains('noapp=1')) {
      url = url.contains('?') ? '$url&_webview=1&noapp=1' : '$url?_webview=1&noapp=1';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    String userAgent = Platform.isIOS
        ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1'
        : 'Mozilla/5.0 (Linux; Android 14; SM-G998B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.friendName),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? (Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.yellow),
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(_getProfileUrl()),
              headers: {
                'User-Agent': userAgent,
                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                'Accept-Language': 'en-US,en;q=0.9',
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
            },
            onLoadStart: (controller, url) {
              setState(() {
                isLoading = true;
              });
            },
            onLoadStop: (controller, url) async {
              setState(() {
                isLoading = false;
              });
            },
            onProgressChanged: (controller, progress) {
              if (progress >= 100) {
                setState(() {
                  isLoading = false;
                });
              }
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final url = navigationAction.request.url?.toString() ?? '';
              final urlLower = url.toLowerCase();
              
              // Block Snapchat app schemes and App Store URLs
              if (urlLower.startsWith('snapchat://') ||
                  urlLower.contains('apps.apple.com') ||
                  urlLower.contains('itunes.apple.com') ||
                  urlLower.startsWith('itms://') ||
                  urlLower.startsWith('itms-apps://') ||
                  urlLower.contains('play.google.com/store') ||
                  urlLower.startsWith('market://')) {
                print('Snapchat Profile - Blocking: $url');
                return NavigationActionPolicy.CANCEL;
              }
              
              // Allow all other navigation
              return NavigationActionPolicy.ALLOW;
            },
            onReceivedServerTrustAuthRequest: (controller, challenge) async {
              return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
            },
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
