import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:stay_connected/Platform/tiktok/tiktok_controller.dart';
import 'package:stay_connected/Platform/tiktok/tiktok_search_dialog.dart';

class TikTokIconScreen extends StatelessWidget {
  final String iconName;
  final String platformName;

  const TikTokIconScreen({
    super.key,
    required this.iconName,
    required this.platformName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GetBuilder<TikTokController>(
      builder: (controller) {
        final categoryFriends = controller.icons
            .where((icon) =>
                icon['category'] == iconName &&
                icon['profileUrl'] != null &&
                icon['profileUrl']!.isNotEmpty)
            .toList();

        print('TikTok - Current category: $iconName');
        print('TikTok - Total icons: ${controller.icons.length}');
        print('TikTok - Category friends: ${categoryFriends.length}');
        for (var icon in controller.icons) {
          print(
              'TikTok - Icon: ${icon['name']}, Category: ${icon['category']}, ProfileUrl: ${icon['profileUrl']}');
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
                image: AssetImage('assets/images/img_group_297.jpg'),
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
                                  isDark ? 'assets/images/account_tiktokker.png' : 'assets/images/img_tiktok.png',
                                  width: isDark ? 60 : null,
                                  height: isDark ? 60 : null,
                                  scale: isDark ? null : 0.1,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      size: isDark ? 30 : 50,
                                      color: Colors.grey.shade700,
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
        );
      },
    );
  }

  void _showSearchDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return TikTokSearchDialog(
          iconName: iconName,
          platformName: platformName,
        );
      },
    );
  }

  void _showActionDialog(BuildContext context, String friendName, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: isDark ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    'Friend Options',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Content
                  Text(
                    'What would you like to do with $friendName?',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'CANCEL',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showRenameDialog(context, friendName, index);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'RENAME',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showMoveDialog(context, friendName, index, iconName);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'MOVE',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showDeleteConfirmationDialog(context, friendName, index);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'DELETE',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
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

  void _showRenameDialog(BuildContext context, String oldName, int index) {
  final controller = Get.find<TikTokController>();
  final renameController = TextEditingController(text: oldName);

  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      return Material( // ✅ Needed so Cupertino dialog renders properly
        color: Colors.transparent,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  "Rename Friend",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                // Input Field
                TextField(
                  controller: renameController,
                  autofocus: true,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 20),
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'CANCEL',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
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
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'RENAME',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
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
  final controller = Get.find<TikTokController>();
  final isDark = Theme.of(context).brightness == Brightness.dark;

  // Get all available categories including custom ones
  final allCategories = controller.getAvailableCategories();
  
  // Also get categories that have friends (for debugging)
  final categoriesWithFriends = controller.getCategoriesWithFriends();

  print('TikTok - All Categories: $allCategories');
  print('TikTok - Categories with Friends: $categoriesWithFriends');
  print('TikTok - Current category: $iconName');
  print('TikTok - Total icons in controller: ${controller.icons.length}');
  
  // Debug: Print all icons to see what's stored
  for (var icon in controller.icons) {
    print('TikTok - Icon: ${icon['name']}, Category: ${icon['category']}, ProfileUrl: ${icon['profileUrl']}');
  }

  if (allCategories.isEmpty) {
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

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      'Move Friend',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Content
                    Text(
                      'Move $friendName to which category?',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: CupertinoPicker(
                        itemExtent: 40,
                        onSelectedItemChanged: (int selectedIndex) {
                          setState(() {
                            selectedCategoryIndex = selectedIndex;
                          });
                        },
                        children: allCategories.map((category) {
                          return Center(
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'CANCEL',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
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
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'MOVE',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
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
    },
  );
}

  void _showDeleteConfirmationDialog(BuildContext context, String friendName, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: isDark ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    'Delete Friend',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Content
                  Text(
                    'Are you sure you want to delete $friendName from your $iconName list?',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'CANCEL',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () async {
                          final controller = Get.find<TikTokController>();

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
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'DELETE',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
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
  late WebViewController _controller;
  bool isLoading = true;
  
  String? _capturedVideoUrl;
  
  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'TikTokVideoCapture',
        onMessageReceived: (JavaScriptMessage message) {
          final videoUrl = message.message;
          if (videoUrl.isNotEmpty && videoUrl.startsWith('http')) {
            print('TikTok Profile - Captured video URL: $videoUrl');
            _capturedVideoUrl = videoUrl;
            // Load the video URL directly in the main webview
            Future.microtask(() {
              _controller.loadRequest(Uri.parse(videoUrl));
            });
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            final urlLower = url.toLowerCase();
            
            // Block app scheme redirects and App Store URLs (all variations)
            if (urlLower.startsWith('tiktok://') ||
                urlLower.startsWith('snssdk1233://') ||
                urlLower.startsWith('snssdk1180://') ||
                urlLower.startsWith('snssdk://') ||
                urlLower.startsWith('musical://') ||
                urlLower.startsWith('tt://') ||
                urlLower.contains('apps.apple.com') ||
                urlLower.contains('itunes.apple.com') ||
                urlLower.startsWith('itms://') ||
                urlLower.startsWith('itms-apps://') ||
                urlLower.startsWith('itms-appss://') ||
                urlLower.contains('play.google.com/store') ||
                urlLower.startsWith('market://') ||
                urlLower.contains('app-store') ||
                urlLower.contains('get-app')) {
              print('TikTok Profile - Blocking app redirect: $url');
              _controller.goBack();
              return;
            }
            
            // Inject JavaScript IMMEDIATELY
            if (url.contains('tiktok.com')) {
              _controller.runJavaScript('''
                (function() {
                  // Override location methods IMMEDIATELY
                  const originalLocationHref = Object.getOwnPropertyDescriptor(window, 'location').get;
                  Object.defineProperty(window, 'location', {
                    get: function() {
                      const loc = originalLocationHref.call(window);
                      const originalHref = Object.getOwnPropertyDescriptor(loc, 'href').get;
                      const originalReplace = loc.replace;
                      const originalAssign = loc.assign;
                      
                      Object.defineProperty(loc, 'href', {
                        get: originalHref,
                        set: function(url) {
                          const urlLower = (url || '').toLowerCase();
                          if (urlLower.startsWith('tiktok://') ||
                              urlLower.startsWith('snssdk1233://') ||
                              urlLower.startsWith('snssdk1180://') ||
                              urlLower.startsWith('snssdk://') ||
                              urlLower.startsWith('musical://') ||
                              urlLower.startsWith('tt://') ||
                              urlLower.includes('apps.apple.com') ||
                              urlLower.includes('itunes.apple.com') ||
                              urlLower.startsWith('itms://') ||
                              urlLower.startsWith('itms-apps://')) {
                            console.log('Blocked location.href redirect');
                            return;
                          }
                          originalHref.call(loc);
                          loc.href = url;
                        }
                      });
                      
                      loc.replace = function(url) {
                        const urlLower = (url || '').toLowerCase();
                        if (urlLower.startsWith('tiktok://') ||
                            urlLower.startsWith('snssdk1233://') ||
                            urlLower.startsWith('snssdk1180://') ||
                            urlLower.startsWith('snssdk://') ||
                            urlLower.startsWith('musical://') ||
                            urlLower.startsWith('tt://') ||
                            urlLower.includes('apps.apple.com') ||
                            urlLower.includes('itunes.apple.com') ||
                            urlLower.startsWith('itms://') ||
                            urlLower.startsWith('itms-apps://')) {
                          console.log('Blocked location.replace redirect');
                          return;
                        }
                        return originalReplace.call(loc, url);
                      };
                      
                      loc.assign = function(url) {
                        const urlLower = (url || '').toLowerCase();
                        if (urlLower.startsWith('tiktok://') ||
                            urlLower.startsWith('snssdk1233://') ||
                            urlLower.startsWith('snssdk1180://') ||
                            urlLower.startsWith('snssdk://') ||
                            urlLower.startsWith('musical://') ||
                            urlLower.startsWith('tt://') ||
                            urlLower.includes('apps.apple.com') ||
                            urlLower.includes('itunes.apple.com') ||
                            urlLower.startsWith('itms://') ||
                            urlLower.startsWith('itms-apps://')) {
                          console.log('Blocked location.assign redirect');
                          return;
                        }
                        return originalAssign.call(loc, url);
                      };
                      
                      return loc;
                    }
                  });
                  
                  // Intercept video/image thumbnail clicks and capture URLs
                  function interceptVideoClicks(e) {
                    let target = e.target;
                    let depth = 0;
                    
                    console.log('TikTok - Click intercepted on:', target, target.tagName, target.className);
                    
                    // Search up the DOM tree for video information
                    while (target && target !== document && depth < 25) {
                      // Check the element itself and all its parents
                      let element = target;
                      let searchDepth = 0;
                      
                      while (element && searchDepth < 15) {
                        // Get all attributes
                        if (element.attributes) {
                          for (let i = 0; i < element.attributes.length; i++) {
                            const attr = element.attributes[i];
                            const attrName = attr.name.toLowerCase();
                            const attrValue = attr.value;
                            
                            console.log('TikTok - Checking attribute:', attrName, '=', attrValue);
                            
                            // Look for video URLs in any attribute
                            if (attrValue && typeof attrValue === 'string') {
                              if (attrValue.includes('tiktok.com') && attrValue.includes('/video/')) {
                                const videoMatch = attrValue.match(/https?:\\/\\/[^\\s"']*tiktok\\.com[^\\s"']*\\/video\\/[^\\s"']+/);
                                if (videoMatch) {
                                  console.log('TikTok - Found video URL in attribute:', videoMatch[0]);
                                  if (window.TikTokVideoCapture) {
                                    e.preventDefault();
                                    e.stopPropagation();
                                    e.stopImmediatePropagation();
                                    window.TikTokVideoCapture.postMessage(videoMatch[0]);
                                    return false;
                                  }
                                }
                              }
                              
                              // Look for video IDs (long numeric strings)
                              const idMatch = attrValue.match(/\\/video\\/(\\d+)/);
                              if (idMatch) {
                                const videoId = idMatch[1];
                                const currentUrl = window.location.href;
                                const profileMatch = currentUrl.match(/tiktok\\.com\\/(@[^\\/]+)/);
                                if (profileMatch) {
                                  const videoUrl = 'https://www.tiktok.com/' + profileMatch[1] + '/video/' + videoId;
                                  console.log('TikTok - Constructed video URL from ID in attribute:', videoUrl);
                                  if (window.TikTokVideoCapture) {
                                    e.preventDefault();
                                    e.stopPropagation();
                                    e.stopImmediatePropagation();
                                    window.TikTokVideoCapture.postMessage(videoUrl);
                                    return false;
                                  }
                                }
                              }
                            }
                            
                            // Look for standalone video IDs (long numbers)
                            if (attrName.includes('id') || attrName.includes('video') || attrName.includes('item')) {
                              const idRegex = new RegExp('^\\\\d{10,}\$');
                              if (attrValue && idRegex.test(attrValue)) {
                                const currentUrl = window.location.href;
                                const profileMatch = currentUrl.match(/tiktok\\.com\\/(@[^\\/]+)/);
                                if (profileMatch) {
                                  const videoUrl = 'https://www.tiktok.com/' + profileMatch[1] + '/video/' + attrValue;
                                  console.log('TikTok - Constructed video URL from ID attribute:', videoUrl);
                                  if (window.TikTokVideoCapture) {
                                    e.preventDefault();
                                    e.stopPropagation();
                                    e.stopImmediatePropagation();
                                    window.TikTokVideoCapture.postMessage(videoUrl);
                                    return false;
                                  }
                                }
                              }
                            }
                          }
                        }
                        
                        // Check innerHTML for video URLs
                        if (element.innerHTML) {
                          const htmlMatch = element.innerHTML.match(/https?:\\/\\/[^\\s"']*tiktok\\.com[^\\s"']*\\/video\\/[^\\s"']+/);
                          if (htmlMatch) {
                            console.log('TikTok - Found video URL in innerHTML:', htmlMatch[0]);
                            if (window.TikTokVideoCapture) {
                              e.preventDefault();
                              e.stopPropagation();
                              e.stopImmediatePropagation();
                              window.TikTokVideoCapture.postMessage(htmlMatch[0]);
                              return false;
                            }
                          }
                        }
                        
                        // Check for links
                        if (element.tagName === 'A') {
                          const href = element.href || element.getAttribute('href') || '';
                          if (href && href.includes('tiktok.com') && href.includes('/video/')) {
                            console.log('TikTok - Found video URL in link href:', href);
                            if (window.TikTokVideoCapture) {
                              e.preventDefault();
                              e.stopPropagation();
                              e.stopImmediatePropagation();
                              window.TikTokVideoCapture.postMessage(href);
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
                    
                    console.log('TikTok - No video URL found in clicked element');
                  }
                  
                  // Add listeners with high priority - BEFORE other listeners
                  document.addEventListener('click', interceptVideoClicks, true);
                  document.addEventListener('touchend', interceptVideoClicks, true);
                  document.addEventListener('touchstart', interceptVideoClicks, true);
                  document.addEventListener('mousedown', interceptVideoClicks, true);
                  
                  // Also intercept after page loads
                  if (document.readyState === 'loading') {
                    document.addEventListener('DOMContentLoaded', function() {
                      document.addEventListener('click', interceptVideoClicks, true);
                      document.addEventListener('touchend', interceptVideoClicks, true);
                    });
                  } else {
                    // Page already loaded, add listeners immediately
                    document.addEventListener('click', interceptVideoClicks, true);
                    document.addEventListener('touchend', interceptVideoClicks, true);
                  }
                  
                  // Also add click handlers to all existing video thumbnails
                  function addClickHandlersToThumbnails() {
                    const thumbnails = document.querySelectorAll('[class*="video"], [class*="item"], [data-e2e*="video"], [class*="thumbnail"], a[href*="tiktok"]');
                    thumbnails.forEach(function(thumb) {
                      if (!thumb.hasAttribute('data-tiktok-handler')) {
                        thumb.setAttribute('data-tiktok-handler', 'true');
                        thumb.addEventListener('click', interceptVideoClicks, true);
                        thumb.addEventListener('touchend', interceptVideoClicks, true);
                      }
                    });
                  }
                  
                  addClickHandlersToThumbnails();
                  
                  // Watch for new thumbnails added dynamically
                  const observer = new MutationObserver(function(mutations) {
                    addClickHandlersToThumbnails();
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
                  
                  // Intercept ALL clicks immediately
                  document.addEventListener('click', function(e) {
                    let target = e.target;
                    while (target && target !== document) {
                      if (target.tagName === 'A' && target.href) {
                        const href = target.href.toLowerCase();
                        if (href.startsWith('tiktok://') || 
                            href.startsWith('snssdk1233://') ||
                            href.startsWith('snssdk1180://') ||
                            href.startsWith('snssdk://') ||
                            href.startsWith('musical://') ||
                            href.startsWith('tt://') ||
                            href.includes('apps.apple.com') ||
                            href.includes('itunes.apple.com') ||
                            href.startsWith('itms://') ||
                            href.startsWith('itms-apps://') ||
                            href.includes('play.google.com/store') ||
                            href.startsWith('market://')) {
                          e.preventDefault();
                          e.stopPropagation();
                          e.stopImmediatePropagation();
                          target.style.pointerEvents = 'none';
                          return false;
                        }
                      }
                      target = target.parentElement;
                    }
                  }, true);
                  
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
                          urlLower.includes('apps.apple.com') ||
                          urlLower.includes('itunes.apple.com') ||
                          urlLower.startsWith('itms://') ||
                          urlLower.startsWith('itms-apps://')) {
                        console.log('Blocked window.open');
                        return null;
                      }
                    }
                    return originalOpen.call(window, url, target, features);
                  };
                })();
              ''');
            }
            
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            // Inject JavaScript to prevent app redirects and extract video info
            if (url.contains('tiktok.com')) {
              _controller.runJavaScript('''
                (function() {
                  // Try to extract video data from page's JavaScript state
                  function extractVideoDataFromPage() {
                    try {
                      // Check window.__UNIVERSAL_DATA_FOR_REHYDRATION__ or similar TikTok data structures
                      if (window.__UNIVERSAL_DATA_FOR_REHYDRATION__) {
                        const data = window.__UNIVERSAL_DATA_FOR_REHYDRATION__;
                        console.log('TikTok - Found page data:', Object.keys(data));
                      }
                      
                      // Check for video data in script tags
                      const scripts = document.querySelectorAll('script[type="application/json"]');
                      for (let script of scripts) {
                        try {
                          const data = JSON.parse(script.textContent);
                          if (data && typeof data === 'object') {
                            // Look for video URLs or IDs in the data
                            const dataStr = JSON.stringify(data);
                            const videoUrlMatch = dataStr.match(/https?:\\/\\/[^\\s"']*tiktok\\.com[^\\s"']*\\/video\\/[^\\s"']+/);
                            if (videoUrlMatch) {
                              console.log('TikTok - Found video URL in page data:', videoUrlMatch[0]);
                            }
                          }
                        } catch(e) {}
                      }
                    } catch(e) {
                      console.log('TikTok - Error extracting page data:', e);
                    }
                  }
                  
                  // Extract video data after page loads
                  setTimeout(extractVideoDataFromPage, 1000);
                  setTimeout(extractVideoDataFromPage, 3000);
                  
                  // Prevent app redirects by intercepting link clicks
                  document.addEventListener('click', function(e) {
                    const target = e.target.closest('a');
                    if (target && target.href) {
                      const href = target.href.toLowerCase();
                      if (href.startsWith('tiktok://') || 
                          href.startsWith('snssdk1233://') ||
                          href.startsWith('snssdk1180://') ||
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
                  }, true);
                  
                  // Override window.open
                  const originalOpen = window.open;
                  window.open = function(url, target, features) {
                    if (url && (url.toLowerCase().startsWith('tiktok://') ||
                        url.toLowerCase().includes('apps.apple.com') ||
                        url.toLowerCase().includes('itunes.apple.com'))) {
                      return null;
                    }
                    return originalOpen.call(window, url, target, features);
                  };
                  
                  // Remove app download prompts
                  function removeAppPrompts() {
                    const selectors = [
                      '[class*="download"]',
                      '[class*="app"]',
                      'a[href*="apps.apple.com"]',
                      'a[href*="play.google.com"]',
                      'a[href*="tiktok://"]'
                    ];
                    selectors.forEach(selector => {
                      try {
                        document.querySelectorAll(selector).forEach(el => {
                          const text = (el.textContent || '').toLowerCase();
                          const href = (el.href || '').toLowerCase();
                          if (text.includes('download') || 
                              text.includes('app store') ||
                              href.includes('apps.apple.com') ||
                              href.startsWith('tiktok://')) {
                            el.style.display = 'none';
                            el.remove();
                          }
                        });
                      } catch(e) {}
                    });
                  }
                  
                  removeAppPrompts();
                  setTimeout(removeAppPrompts, 500);
                  setTimeout(removeAppPrompts, 1000);
                })();
              ''');
            }
            
            setState(() {
              isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url.toLowerCase();
            final originalUrl = request.url;
            
            // Block TikTok redirect URLs - try to extract video URL and load it
            if (url.contains('tiktokv.com/redirect') || url.contains('tiktok.com/redirect')) {
              print('TikTok Profile - Blocking redirect: $originalUrl');
              
              // Check if we have a captured video URL from JavaScript
              if (_capturedVideoUrl != null) {
                print('TikTok Profile - Loading captured video URL in webview: $_capturedVideoUrl');
                final capturedUrl = _capturedVideoUrl!;
                _capturedVideoUrl = null; // Reset
                // Load the video URL directly in the webview
                Future.microtask(() {
                  _controller.loadRequest(Uri.parse(capturedUrl));
                });
                return NavigationDecision.prevent;
              }
              
              // Try to extract video URL from page context using JavaScript
              Future.microtask(() {
                _controller.runJavaScript('''
                  (function() {
                    try {
                      // Get current page URL to extract profile
                      const currentUrl = window.location.href;
                      const profileMatch = currentUrl.match(/tiktok\\.com\\/(@[^\\/]+)/);
                      if (!profileMatch) {
                        console.log('TikTok - No profile match found');
                        return;
                      }
                      
                      // Look for video information in the page
                      // Check for video items in the DOM
                      const videoItems = document.querySelectorAll('[data-e2e="user-post-item"], [class*="video-item"], [class*="video-card"], a[href*="/video/"], [class*="DivItemContainer"]');
                      console.log('TikTok - Found video items:', videoItems.length);
                      
                      for (let item of videoItems) {
                        // Check href
                        if (item.href && item.href.includes('/video/')) {
                          console.log('TikTok - Found video URL in href:', item.href);
                          if (window.TikTokVideoCapture) {
                            window.TikTokVideoCapture.postMessage(item.href);
                            return;
                          }
                        }
                        
                        // Check data attributes
                        for (let attr of item.attributes) {
                          if (attr.value && attr.value.includes('/video/')) {
                            const match = attr.value.match(/https?:\\/\\/[^\\s"']*tiktok\\.com[^\\s"']*\\/video\\/[^\\s"']+/);
                            if (match) {
                              console.log('TikTok - Found video URL in attribute:', match[0]);
                              if (window.TikTokVideoCapture) {
                                window.TikTokVideoCapture.postMessage(match[0]);
                                return;
                              }
                            }
                          }
                          
                          // Check for video ID
                          if (attr.name.includes('id') || attr.name.includes('video') || attr.name.includes('item')) {
                            const idMatch = attr.value.match(/\\/video\\/(\\d+)/);
                            if (idMatch) {
                              const videoUrl = 'https://www.tiktok.com/' + profileMatch[1] + '/video/' + idMatch[1];
                              console.log('TikTok - Constructed video URL from ID:', videoUrl);
                              if (window.TikTokVideoCapture) {
                                window.TikTokVideoCapture.postMessage(videoUrl);
                                return;
                              }
                            }
                            
                            // Long numeric ID (TikTok video IDs are usually 19 digits)
                            const idRegex = new RegExp('^\\\\d{15,}\$');
                            if (idRegex.test(attr.value)) {
                              const videoUrl = 'https://www.tiktok.com/' + profileMatch[1] + '/video/' + attr.value;
                              console.log('TikTok - Constructed video URL from numeric ID:', videoUrl);
                              if (window.TikTokVideoCapture) {
                                window.TikTokVideoCapture.postMessage(videoUrl);
                                return;
                              }
                            }
                          }
                        }
                      }
                      
                      // Check page data
                      if (window.__UNIVERSAL_DATA_FOR_REHYDRATION__) {
                        const data = JSON.stringify(window.__UNIVERSAL_DATA_FOR_REHYDRATION__);
                        const videoMatch = data.match(/https?:\\/\\/[^\\s"']*tiktok\\.com[^\\s"']*\\/video\\/[^\\s"']+/);
                        if (videoMatch) {
                          console.log('TikTok - Found video URL in page data:', videoMatch[0]);
                          if (window.TikTokVideoCapture) {
                            window.TikTokVideoCapture.postMessage(videoMatch[0]);
                            return;
                          }
                        }
                      }
                      
                      console.log('TikTok - Could not find video URL in page');
                    } catch(e) {
                      console.log('TikTok - Error extracting video URL:', e);
                    }
                  })();
                ''').catchError((error) {
                  print('TikTok Profile - JavaScript error (ignored): $error');
                });
              });
              
              return NavigationDecision.prevent;
            }
            
            // Block app scheme redirects and App Store URLs (all variations)
            if (url.startsWith('tiktok://') ||
                url.startsWith('snssdk1233://') ||
                url.startsWith('snssdk1180://') ||
                url.startsWith('snssdk://') ||
                url.startsWith('musical://') ||
                url.startsWith('tt://') ||
                url.contains('apps.apple.com') ||
                url.contains('itunes.apple.com') ||
                url.startsWith('itms://') ||
                url.startsWith('itms-apps://') ||
                url.startsWith('itms-appss://') ||
                url.contains('play.google.com/store') ||
                url.startsWith('market://') ||
                url.contains('app-store') ||
                url.contains('get-app')) {
              print('TikTok Profile - Blocking navigation to: $originalUrl');
              return NavigationDecision.prevent;
            }

            // Block universal links that might trigger app redirects
            if (url.contains('tiktok.com') && 
                (url.contains('/app/') || 
                 url.contains('/download') ||
                 url.contains('/install') ||
                 url.contains('open-app') ||
                 url.contains('deep-link') ||
                 url.contains('app_redirect') ||
                 url.contains('open_app') ||
                 url.contains('app_link'))) {
              print('TikTok Profile - Blocking app download/deep link: $originalUrl');
              return NavigationDecision.prevent;
            }

            // If navigating away from tiktok.com to a non-http/https URL, block it
            if (!url.startsWith('http://') && 
                !url.startsWith('https://') && 
                !url.startsWith('about:') &&
                !url.startsWith('data:') &&
                !url.startsWith('javascript:') &&
                !url.startsWith('file://')) {
              print('TikTok Profile - Blocking non-web URL: $originalUrl');
              return NavigationDecision.prevent;
            }
            
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.profileUrl));
  }

  @override
  Widget build(BuildContext context) {
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
          WebViewWidget(controller: _controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
