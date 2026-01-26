import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:stay_connected/Platform/facebook/facebook_controller.dart';
import 'package:stay_connected/Platform/facebook/facebook_webview_screen.dart';
import 'package:stay_connected/Platform/facebook/facebook_constants.dart';

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
                image: AssetImage(FacebookConstants.assetImageGroup173),
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
                          FacebookConstants.emptyCategoryMessage,
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
                                    friendName: friend['name'] ?? FacebookConstants.unknownFriend,
                                  ));
                            }
                          },
                          onLongPress: () {
                            _showActionDialog(
                                context, friend['name'] ?? FacebookConstants.unknownFriend, index);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                child: Image.asset(
                                  isDark ? FacebookConstants.assetAccountFb : FacebookConstants.assetImgFb,
                                  width: isDark ? 60 : null,
                                  height: isDark ? 60 : null,
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
                                  friend['name'] ?? FacebookConstants.unknownFriend,
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
              FacebookConstants.assetPersonAddBlue,
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
              Text(
                FacebookConstants.searchFriendsTitle,
                style: const TextStyle(
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
                  placeholder: FacebookConstants.searchFriendsPlaceholder,
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
                Text(
                  FacebookConstants.searchFriendsHint,
                  style: const TextStyle(
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
                FacebookConstants.cancel,
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
                FacebookConstants.search,
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
                  Text(
                    FacebookConstants.friendOptionsTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${FacebookConstants.friendOptionsMessage} $friendName?',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                FacebookConstants.cancelButton,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextButton(
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
                                FacebookConstants.renameButton,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextButton(
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
                                FacebookConstants.moveButton,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _showDeleteConfirmationDialog(context, friendName, index, iconName);
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                FacebookConstants.deleteButton,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
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
    final controller = Get.find<FaceBookController>();
    final renameController = TextEditingController(text: oldName);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Material(
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
                  Text(
                    FacebookConstants.renameFriendTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
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
                          FacebookConstants.cancelButton,
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

                              await controller.renameIcon(
                                  originalIndex, newName);
                            }

                            Navigator.of(context).pop();
                            final isDark = Theme.of(context).brightness == Brightness.dark;
                            Get.snackbar(
                              FacebookConstants.friendRenamedTitle,
                              '$oldName ${FacebookConstants.friendRenamedMessage} $newName',
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
                          FacebookConstants.renameButton,
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

  void _showMoveDialog(
      BuildContext context, String friendName, int index, String iconName) {
    final controller = Get.find<FaceBookController>();

    final allCategories = controller.getAvailableCategories();
    final categoriesWithFriends = controller.getCategoriesWithFriends();

    print('Facebook - All Categories: $allCategories');
    print('Facebook - Categories with Friends: $categoriesWithFriends');
    print('Facebook - Current category: $iconName');
    print('Facebook - Total icons in controller: ${controller.icons.length}');
    
    for (var icon in controller.icons) {
      print('Facebook - Icon: ${icon['name']}, Category: ${icon['category']}, ProfileUrl: ${icon['profileUrl']}');
    }

    if (allCategories.isEmpty) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      Get.snackbar(
        FacebookConstants.noCategoriesAvailableTitle,
        FacebookConstants.noCategoriesAvailableMessage,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: isDark ? Colors.orange[900] : Colors.orange.shade100,
        colorText: isDark ? Colors.orange[100] : Colors.orange.shade800,
      );
      return;
    }

    int selectedCategoryIndex = 0;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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
                      Text(
                        FacebookConstants.moveFriendTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${FacebookConstants.moveFriendMessage} $friendName ${FacebookConstants.moveFriendTo}',
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
                              FacebookConstants.cancelButton,
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
                                  FacebookConstants.friendMovedTitle,
                                  '$friendName ${FacebookConstants.friendMovedMessage} $selectedCategory',
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
                              FacebookConstants.moveButton,
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

  void _showDeleteConfirmationDialog(
      BuildContext context, String friendName, int index, String iconName) {
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
                  Text(
                    FacebookConstants.deleteFriendTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${FacebookConstants.deleteFriendMessage} $friendName ${FacebookConstants.deleteFriendFrom} $iconName ${FacebookConstants.deleteFriendList}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
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
                          FacebookConstants.cancelButton,
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
                            FacebookConstants.friendDeletedTitle,
                            '$friendName ${FacebookConstants.friendDeletedMessage} $iconName list',
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
                          FacebookConstants.deleteButton,
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
  InAppWebViewController? webViewController;
  bool isLoading = true;

  String _getProfileUrl() {
    String url = widget.profileUrl;
    if (!url.contains(FacebookConstants.webviewParam1) && !url.contains(FacebookConstants.webviewParam2)) {
      url = url.contains('?') 
          ? '$url&${FacebookConstants.webviewParam1}&${FacebookConstants.webviewParam2}' 
          : '$url?${FacebookConstants.webviewParam1}&${FacebookConstants.webviewParam2}';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    String userAgent = Platform.isIOS
        ? FacebookConstants.iosUserAgent
        : FacebookConstants.androidUserAgent;

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
                'Accept': FacebookConstants.acceptHeader,
                'Accept-Language': FacebookConstants.acceptLanguageHeader,
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
              
              controller.addUserScript(
                userScript: UserScript(
                  source: FacebookConstants.blockingScript,
                  injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                ),
              );
            },
            onLoadStart: (controller, url) {
              setState(() {
                isLoading = true;
              });
              
              controller.evaluateJavascript(source: FacebookConstants.blockingScriptSimple);
            },
            onLoadStop: (controller, url) async {
              setState(() {
                isLoading = false;
              });
              
              await controller.evaluateJavascript(source: FacebookConstants.blockingScriptWithWindowOpen);
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
              
              if (urlLower.contains('applink.facebook.com')) {
                print('Facebook Profile - Blocking applink URL: $url');
                return NavigationActionPolicy.CANCEL;
              }
              
              if (urlLower.contains('launch_app_store=true')) {
                print('Facebook Profile - Blocking URL with launch_app_store: $url');
                return NavigationActionPolicy.CANCEL;
              }
              
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
              
              if (urlLower.contains('fbsbx.com') || urlLower.contains('facebook.com/tr/')) {
                print('Facebook Profile - Blocking tracking URL, staying on profile');
                return NavigationActionPolicy.CANCEL;
              }
              
              if (urlLower.contains('facebook.com') &&
                  !urlLower.contains(FacebookConstants.webviewParam1) &&
                  !urlLower.contains(FacebookConstants.webviewParam2)) {
                print('Facebook Profile - Modifying URL to prevent Universal Links: $url');
                final modifiedUrl = url.contains('?')
                    ? '$url&${FacebookConstants.webviewParam1}&${FacebookConstants.webviewParam2}'
                    : '$url?${FacebookConstants.webviewParam1}&${FacebookConstants.webviewParam2}';
                Future.microtask(() async {
                  await controller.loadUrl(urlRequest: URLRequest(url: WebUri(modifiedUrl)));
                });
                return NavigationActionPolicy.CANCEL;
              }
              
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
