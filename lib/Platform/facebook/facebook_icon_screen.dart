import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:stay_connected/Platform/facebook/facebook_controller.dart';
import 'package:stay_connected/Platform/facebook/facebook_webview_screen.dart';

class FacebookIconScreen extends StatelessWidget {
  final String iconName;
  final String platformName;

  const FacebookIconScreen({
    super.key,
    required this.iconName,
    required this.platformName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GetBuilder<FaceBookController>(
      builder: (controller) {
        final categoryFriends = controller.icons
            .where((icon) =>
                icon['category'] == iconName &&
                icon['profileUrl'] != null &&
                icon['profileUrl']!.isNotEmpty)
            .toList();

        print('Facebook - Current category: $iconName');
        print('Facebook - Total icons: ${controller.icons.length}');
        print('Facebook - Category friends: ${categoryFriends.length}');
        for (var icon in controller.icons) {
          print(
              'Facebook - Icon: ${icon['name']}, Category: ${icon['category']}, ProfileUrl: ${icon['profileUrl']}');
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(iconName),
            centerTitle: true,
            backgroundColor: isDark ? theme.appBarTheme.backgroundColor : Colors.white,
            foregroundColor: isDark ? theme.appBarTheme.foregroundColor : Colors.black,
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
          body: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.black : null,
              image: isDark ? null : DecorationImage(
                image: AssetImage('assets/images/img_group_173.jpg'),
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
                            // Open the fried's profile in WebView
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
                                  isDark ? 'assets/images/iconnew_nbg.png' : 'assets/images/img_fb.png',
                                  width: isDark ? 30 : null,
                                  height: isDark ? 30 : null,
                                  scale: isDark ? null : 0.1,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      size: isDark ? 30 : 50,
                                      color: Colors.blue.shade700,
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
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
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
        );
      },
    );
  }

  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController();

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Row(
            children: [
              const Icon(
                CupertinoIcons.search,
                color: CupertinoColors.systemBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Search Friends',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              children: [
                CupertinoTextField(
                  controller: searchController,
                  autofocus: true,
                  placeholder: 'Enter friend name or URL',
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Search and add friends to your category',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
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
                final searchQuery = searchController.text.trim();
                if (searchQuery.isNotEmpty) {
                  Navigator.of(context).pop();

                  Get.to(() => FacebookWebviewScreen(
                        searchQuery: searchQuery,
                        iconName: iconName,
                        platformName: platformName,
                      ));
                }
              },
              isDefaultAction: true,
              child: const Text(
                'Search',
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
          ],
        );
      },
    );
  }

  void _showRenameDialog(BuildContext context, String oldName, int index) {
    final controller = Get.find<FaceBookController>();
    final renameController = TextEditingController(text: oldName);

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return Material(
          // ✅ Needed so Cupertino dialog renders properly
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
                mainAxisSize:
                    MainAxisSize.min, // ✅ prevents unnecessary scrolling
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

                              await controller.renameIcon(
                                  originalIndex, newName);
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

  void _showMoveDialog(
      BuildContext context, String friendName, int index, String iconName) {
    final controller = Get.find<FaceBookController>();

    // Get all available categories including custom ones
    final allCategories = controller.getAvailableCategories();
    
    // Also get categories that have friends (for debugging)
    final categoriesWithFriends = controller.getCategoriesWithFriends();

    print('Facebook - All Categories: $allCategories');
    print('Facebook - Categories with Friends: $categoriesWithFriends');
    print('Facebook - Current category: $iconName');
    print('Facebook - Total icons in controller: ${controller.icons.length}');
    
    // Debug: Print all icons to see what's stored
    for (var icon in controller.icons) {
      print('Facebook - Icon: ${icon['name']}, Category: ${icon['category']}, ProfileUrl: ${icon['profileUrl']}');
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
                  final selectedCategory = allCategories[selectedCategoryIndex];

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
                      selectedCategory,
                      friendToMove['profileUrl']!,
                    );
                  }

                  Navigator.of(context).pop();
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  Get.snackbar(
                    'Friend Moved',
                    '$friendName has been moved to $selectedCategory',
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

  void _showDeleteConfirmationDialog(
      BuildContext context, String friendName, int index) {
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
                final controller = Get.find<FaceBookController>();

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
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? (Theme.of(context).appBarTheme.backgroundColor ?? Colors.grey[900]) : Colors.white,
        foregroundColor: Theme.of(context).brightness == Brightness.dark ? (Theme.of(context).appBarTheme.foregroundColor ?? Colors.white) : Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[300],
          ),
        ),
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
              
              // Inject blocking script at document start
              controller.addUserScript(
                userScript: UserScript(
                  source: '''
                    (function() {
                      if (window.facebookBlockingLoaded) return;
                      window.facebookBlockingLoaded = true;
                      
                      // Block all clicks that would open Facebook app
                      document.addEventListener('click', function(e) {
                        let target = e.target;
                        let depth = 0;
                        while (target && target !== document && depth < 10) {
                          if (target.tagName === 'A' && target.href) {
                            const href = target.href.toLowerCase();
                            if (href.startsWith('fb://') ||
                                href.startsWith('fbapi://') ||
                                href.startsWith('fbauth2://') ||
                                href.includes('applink.facebook.com') ||
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
                          if (urlLower.startsWith('fb://') ||
                              urlLower.startsWith('fbapi://') ||
                              urlLower.startsWith('fbauth2://') ||
                              urlLower.includes('applink.facebook.com') ||
                              urlLower.includes('apps.apple.com') ||
                              urlLower.includes('itunes.apple.com')) {
                            return null;
                          }
                        }
                        return originalOpen.call(window, url, target, features);
                      };
                      
                      // Override location methods
                      const originalHref = Object.getOwnPropertyDescriptor(window, 'location').get;
                      Object.defineProperty(window, 'location', {
                        get: function() {
                          const loc = originalHref.call(window);
                          const originalAssign = loc.assign;
                          const originalReplace = loc.replace;
                          
                          loc.assign = function(url) {
                            const urlLower = (url || '').toLowerCase();
                            if (urlLower.startsWith('fb://') ||
                                urlLower.startsWith('fbapi://') ||
                                urlLower.startsWith('fbauth2://') ||
                                urlLower.includes('applink.facebook.com')) {
                              return;
                            }
                            return originalAssign.call(loc, url);
                          };
                          
                          loc.replace = function(url) {
                            const urlLower = (url || '').toLowerCase();
                            if (urlLower.startsWith('fb://') ||
                                urlLower.startsWith('fbapi://') ||
                                urlLower.startsWith('fbauth2://') ||
                                urlLower.includes('applink.facebook.com')) {
                              return;
                            }
                            return originalReplace.call(loc, url);
                          };
                          
                          return loc;
                        }
                      });
                    })();
                  ''',
                  injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                ),
              );
            },
            onLoadStart: (controller, url) {
              setState(() {
                isLoading = true;
              });
              
              // Inject blocking script early
              controller.evaluateJavascript(source: '''
                (function() {
                  // Block all clicks that would open Facebook app
                  document.addEventListener('click', function(e) {
                    let target = e.target;
                    let depth = 0;
                    while (target && target !== document && depth < 10) {
                      if (target.tagName === 'A' && target.href) {
                        const href = target.href.toLowerCase();
                        if (href.startsWith('fb://') ||
                            href.startsWith('fbapi://') ||
                            href.startsWith('fbauth2://') ||
                            href.includes('applink.facebook.com') ||
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
              setState(() {
                isLoading = false;
              });
              
              // Inject blocking script again after page loads
              await controller.evaluateJavascript(source: '''
                (function() {
                  // Block all clicks that would open Facebook app
                  document.addEventListener('click', function(e) {
                    let target = e.target;
                    let depth = 0;
                    while (target && target !== document && depth < 10) {
                      if (target.tagName === 'A' && target.href) {
                        const href = target.href.toLowerCase();
                        if (href.startsWith('fb://') ||
                            href.startsWith('fbapi://') ||
                            href.startsWith('fbauth2://') ||
                            href.includes('applink.facebook.com') ||
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
                      if (urlLower.startsWith('fb://') ||
                          urlLower.startsWith('fbapi://') ||
                          urlLower.startsWith('fbauth2://') ||
                          urlLower.includes('applink.facebook.com') ||
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
              if (progress >= 100) {
                setState(() {
                  isLoading = false;
                });
              }
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final url = navigationAction.request.url?.toString() ?? '';
              final urlLower = url.toLowerCase();
              
              print('Facebook Profile - Navigation request to: $url');
              
              // Block applink.facebook.com URLs (Universal Links)
              if (urlLower.contains('applink.facebook.com')) {
                print('Facebook Profile - Blocking applink URL: $url');
                return NavigationActionPolicy.CANCEL;
              }
              
              // Block URLs with launch_app_store parameter
              if (urlLower.contains('launch_app_store=true')) {
                print('Facebook Profile - Blocking URL with launch_app_store: $url');
                return NavigationActionPolicy.CANCEL;
              }
              
              // Block Facebook app schemes and App Store URLs
              if (urlLower.startsWith('fb://') ||
                  urlLower.startsWith('fbapi://') ||
                  urlLower.startsWith('fbauth2://') ||
                  urlLower.contains('apps.apple.com') ||
                  urlLower.contains('itunes.apple.com') ||
                  urlLower.startsWith('itms://') ||
                  urlLower.startsWith('itms-apps://') ||
                  urlLower.contains('play.google.com/store') ||
                  urlLower.startsWith('market://')) {
                print('Facebook Profile - Blocking app scheme/App Store URL: $url');
                return NavigationActionPolicy.CANCEL;
              }
              
              // Block tracking URLs (fbsbx.com) - redirect back to main profile
              if (urlLower.contains('fbsbx.com') || urlLower.contains('facebook.com/tr/')) {
                print('Facebook Profile - Blocking tracking URL, staying on profile');
                return NavigationActionPolicy.CANCEL;
              }
              
              // For Facebook URLs, ensure _webview=1&noapp=1 parameters are present
              if (urlLower.contains('facebook.com') &&
                  !urlLower.contains('_webview=1') &&
                  !urlLower.contains('noapp=1')) {
                print('Facebook Profile - Modifying URL to prevent Universal Links: $url');
                final modifiedUrl = url.contains('?')
                    ? '$url&_webview=1&noapp=1'
                    : '$url?_webview=1&noapp=1';
                Future.microtask(() async {
                  await controller.loadUrl(urlRequest: URLRequest(url: WebUri(modifiedUrl)));
                });
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
