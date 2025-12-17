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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
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
            backgroundColor: theme.appBarTheme.backgroundColor,
            foregroundColor: theme.appBarTheme.foregroundColor,
            elevation: 0,
          ),
          body: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.black : null,
              image: isDark ? null : DecorationImage(
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
                            // Open the friend's profile in WebView
                            if (friend['profileUrl'] != null) {
                              Get.to(() => FriendProfileScreen(
                                    profileUrl: friend['profileUrl']!,
                                    friendName: friend['name'] ?? 'Unknown',
                                  ));
                            }
                          },
                          onLongPress: () {
                            // Show action dialog on long press
                            _showActionDialog(
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

void _showMoveDialog(BuildContext context, String friendName, int index, String iconName) {
  final controller = Get.find<InstagramController>();
  final isDark = Theme.of(context).brightness == Brightness.dark;

  // Get all available categories including custom ones
  final allCategories = controller.getAvailableCategories();
  
  // Also get categories that have friends (for debugging)
  final categoriesWithFriends = controller.getCategoriesWithFriends();

  print('Instagram - All Categories: $allCategories');
  print('Instagram - Categories with Friends: $categoriesWithFriends');
  print('Instagram - Current category: $iconName');
  print('Instagram - Total icons in controller: ${controller.icons.length}');
  
  // Debug: Print all icons to see what's stored
  for (var icon in controller.icons) {
    print('Instagram - Icon: ${icon['name']}, Category: ${icon['category']}, ProfileUrl: ${icon['profileUrl']}');
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
void _showRenameDialog(BuildContext context, String oldName, int index) {
  final controller = Get.find<InstagramController>();
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

class FriendProfileScreen extends StatefulWidget {
  final String profileUrl;
  final String friendName;

  const FriendProfileScreen({
    super.key,
    required this.profileUrl,
    required this.friendName,
  });

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  bool isLoading = true;
  String? _capturedPostUrl;
  InAppWebViewController? _webViewController;

  static const String iosUserAgent =
      'Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) '
      'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 '
      'Mobile/15E148 Safari/604.1';

  String _getProfileUrl() {
    String url = widget.profileUrl;
    // Add parameters to prevent Universal Links if not already present
    if (!url.contains('_webview=1') && !url.contains('noapp=1')) {
      url = url.contains('?') ? '$url&_webview=1&noapp=1' : '$url?_webview=1&noapp=1';
    }
    return url;
  }

  @override
  void initState() {
    super.initState();
  }

  String _getPostCaptureScript() {
    return '''
      (function() {
        if (window.instagramPostCaptureLoaded) return;
        window.instagramPostCaptureLoaded = true;
        
        // Store the last clicked element to extract post URL from
        let lastClickedElement = null;
        
        // Intercept clicks on posts/images/videos to capture URLs
        function interceptPostClicks(e) {
          try {
            console.log('Instagram - Click intercepted on:', e.target);
            lastClickedElement = e.target;
            
            let target = e.target;
            let depth = 0;
            const maxDepth = 20;
            
            while (target && target !== document && depth < maxDepth) {
              let element = target;
              let searchDepth = 0;
              const maxSearchDepth = 12;
              
              while (element && element !== document && searchDepth < maxSearchDepth) {
                // Check for Instagram post URLs in href (most common case)
                if (element.tagName === 'A' && element.href) {
                  const href = element.href;
                  console.log('Instagram - Checking link href:', href);
                  if (href.includes('instagram.com/p/') || 
                      href.includes('instagram.com/reel/') ||
                      href.includes('instagram.com/tv/') ||
                      href.includes('/p/') ||
                      href.includes('/reel/') ||
                      href.includes('/tv/') ||
                      href.includes('/reels/')) {
                    console.log('Instagram - Found post URL in link:', href);
                    // Extract clean post URL
                    let postUrl = href;
                    if (postUrl.includes('?')) {
                      postUrl = postUrl.split('?')[0];
                    }
                    // Ensure it's a full URL
                    if (!postUrl.startsWith('http')) {
                      if (postUrl.startsWith('/')) {
                        postUrl = 'https://www.instagram.com' + postUrl;
                      } else {
                        postUrl = 'https://www.instagram.com/' + postUrl;
                      }
                    }
                    console.log('Instagram - Sending post URL to handler:', postUrl);
                    if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                      e.preventDefault();
                      e.stopPropagation();
                      e.stopImmediatePropagation();
                      window.flutter_inappwebview.callHandler('InstagramPostCapture', postUrl).catch(function(err) {
                        console.error('Instagram - Error calling handler:', err);
                      });
                      return false;
                    }
                  }
                }
                
                // Check for link in parent elements
                const linkElement = element.closest('a');
                if (linkElement && linkElement.href) {
                  const href = linkElement.href;
                  if (href.includes('instagram.com/p/') || 
                      href.includes('instagram.com/reel/') ||
                      href.includes('instagram.com/tv/') ||
                      href.includes('/p/') ||
                      href.includes('/reel/') ||
                      href.includes('/tv/') ||
                      href.includes('/reels/')) {
                    console.log('Instagram - Found post URL in parent link:', href);
                    let postUrl = href;
                    if (postUrl.includes('?')) {
                      postUrl = postUrl.split('?')[0];
                    }
                    if (!postUrl.startsWith('http')) {
                      if (postUrl.startsWith('/')) {
                        postUrl = 'https://www.instagram.com' + postUrl;
                      } else {
                        postUrl = 'https://www.instagram.com/' + postUrl;
                      }
                    }
                    console.log('Instagram - Sending post URL to handler:', postUrl);
                    if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                      e.preventDefault();
                      e.stopPropagation();
                      e.stopImmediatePropagation();
                      window.flutter_inappwebview.callHandler('InstagramPostCapture', postUrl).catch(function(err) {
                        console.error('Instagram - Error calling handler:', err);
                      });
                      return false;
                    }
                  }
                }
                
                // Check data attributes for post URLs
                if (element.attributes) {
                  for (let attr of element.attributes) {
                    const attrValue = attr.value;
                    if (attrValue && typeof attrValue === 'string') {
                      if (attrValue.includes('instagram.com/p/') || 
                          attrValue.includes('instagram.com/reel/') ||
                          attrValue.includes('instagram.com/tv/') ||
                          attrValue.includes('/p/') ||
                          attrValue.includes('/reel/') ||
                          attrValue.includes('/tv/') ||
                          attrValue.includes('/reels/')) {
                        const urlMatch = attrValue.match(/https?:\\/\\/[^\\s"']*instagram\\.com\\/(p|reel|tv|reels)\\/[^\\s"']+/);
                        if (urlMatch) {
                          console.log('Instagram - Found post URL in attribute:', urlMatch[0]);
                          let postUrl = urlMatch[0];
                          if (postUrl.includes('?')) {
                            postUrl = postUrl.split('?')[0];
                          }
                          console.log('Instagram - Sending post URL to handler:', postUrl);
                          if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                            e.preventDefault();
                            e.stopPropagation();
                            e.stopImmediatePropagation();
                            window.flutter_inappwebview.callHandler('InstagramPostCapture', postUrl).catch(function(err) {
                              console.error('Instagram - Error calling handler:', err);
                            });
                            return false;
                          }
                        }
                      }
                    }
                  }
                }
                
                // Check innerHTML for post URLs
                if (element.innerHTML) {
                  const htmlMatch = element.innerHTML.match(/https?:\\/\\/[^\\s"']*instagram\\.com\\/(p|reel|tv|reels)\\/[^\\s"']+/);
                  if (htmlMatch) {
                    console.log('Instagram - Found post URL in innerHTML:', htmlMatch[0]);
                    let postUrl = htmlMatch[0];
                    if (postUrl.includes('?')) {
                      postUrl = postUrl.split('?')[0];
                    }
                    console.log('Instagram - Sending post URL to handler:', postUrl);
                    if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
                      e.preventDefault();
                      e.stopPropagation();
                      e.stopImmediatePropagation();
                      window.flutter_inappwebview.callHandler('InstagramPostCapture', postUrl).catch(function(err) {
                        console.error('Instagram - Error calling handler:', err);
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
            console.log('Instagram - Error intercepting click:', err);
          }
        }
        
        // Add listeners with highest priority - BEFORE any other listeners
        document.addEventListener('click', interceptPostClicks, true);
        document.addEventListener('touchend', interceptPostClicks, true);
        document.addEventListener('touchstart', interceptPostClicks, true);
        document.addEventListener('mousedown', interceptPostClicks, true);
        
        // Also intercept after page loads
        if (document.readyState === 'loading') {
          document.addEventListener('DOMContentLoaded', function() {
            document.addEventListener('click', interceptPostClicks, true);
            document.addEventListener('touchend', interceptPostClicks, true);
          });
        } else {
          document.addEventListener('click', interceptPostClicks, true);
          document.addEventListener('touchend', interceptPostClicks, true);
        }
        
        // Add click handlers to all existing post thumbnails
        function addClickHandlersToPosts() {
          const posts = document.querySelectorAll('[class*="post"], [class*="item"], [data-e2e*="post"], [class*="thumbnail"], a[href*="/p/"], a[href*="/reel/"], a[href*="/tv/"], [role="link"], [role="button"]');
          posts.forEach(function(post) {
            if (!post.hasAttribute('data-instagram-handler')) {
              post.setAttribute('data-instagram-handler', 'true');
              post.addEventListener('click', interceptPostClicks, true);
              post.addEventListener('touchend', interceptPostClicks, true);
            }
          });
        }
        
        addClickHandlersToPosts();
        
        // Watch for new posts added dynamically
        const observer = new MutationObserver(function(mutations) {
          addClickHandlersToPosts();
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
        
        // Expose function to extract post URL from last clicked element
        window.getLastClickedPostUrl = function() {
          if (!lastClickedElement) return null;
          let element = lastClickedElement;
          let depth = 0;
          while (element && element !== document && depth < 10) {
            const link = element.closest('a');
            if (link && link.href) {
              const href = link.href;
              if (href.includes('/p/') || href.includes('/reel/') || href.includes('/tv/')) {
                let postUrl = href.split('?')[0];
                if (!postUrl.startsWith('http')) {
                  postUrl = 'https://www.instagram.com' + (postUrl.startsWith('/') ? postUrl : '/' + postUrl);
                }
                return postUrl;
              }
            }
            element = element.parentElement;
            depth++;
          }
          return null;
        };
      })();
    ''';
  }

  bool _isInstagram(String url) => url.contains("instagram.com");

  // Future<void> _openInExternal() async {
  //   final uri = Uri.parse(widget.profileUrl);
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(uri, mode: LaunchMode.externalApplication);
  //   }
  //   if (mounted) Navigator.pop(context); // close screen after fallback
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.friendName),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? (Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.purple),
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor ?? Colors.white,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(_isInstagram(widget.profileUrl) ? _getProfileUrl() : widget.profileUrl),
              headers: {
                'User-Agent': iosUserAgent,
                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
                'Accept-Language': 'en-US,en;q=0.9',
                'Accept-Encoding': 'gzip, deflate, br',
                'Referer': 'https://www.instagram.com/',
                'Origin': 'https://www.instagram.com',
                'Sec-Fetch-Dest': 'document',
                'Sec-Fetch-Mode': 'navigate',
                'Sec-Fetch-Site': 'same-origin',
                'Sec-Fetch-User': '?1',
                'Upgrade-Insecure-Requests': '1',
              },
            ),
            initialSettings: InAppWebViewSettings(
              userAgent: iosUserAgent,
              javaScriptEnabled: true,
              allowsInlineMediaPlayback: true,
              mediaPlaybackRequiresUserGesture: false,
              useShouldOverrideUrlLoading: true,
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
              // Register JavaScript handler for post capture
              controller.addJavaScriptHandler(
                handlerName: 'InstagramPostCapture',
                callback: (args) {
                  if (args.isNotEmpty) {
                    final postUrl = args[0].toString();
                    if (postUrl.isNotEmpty && postUrl.startsWith('http')) {
                      print('Instagram Profile - Captured post URL: $postUrl');
                      _capturedPostUrl = postUrl;
                      Future.microtask(() {
                        controller.loadUrl(urlRequest: URLRequest(url: WebUri(postUrl)));
                      });
                    }
                  }
                },
              );
              
              // Inject post capture script at document start
              controller.addUserScript(
                userScript: UserScript(
                  source: _getPostCaptureScript(),
                  injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                ),
              );
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
              
              // Inject post capture script
              await controller.evaluateJavascript(source: _getPostCaptureScript());
              
              // Inject WebView detection hiding script
              await controller.evaluateJavascript(source: '''
                (function() {
                  Object.defineProperty(navigator, 'webdriver', {
                    get: () => undefined
                  });
                  delete navigator.__proto__.webdriver;
                  Object.defineProperty(navigator, 'plugins', {
                    get: () => [1, 2, 3, 4, 5]
                  });
                  Object.defineProperty(navigator, 'languages', {
                    get: () => ['en-US', 'en']
                  });
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
              final originalUrl = url;
              
              print('Instagram Profile - Navigation request to: $originalUrl');
              
              // Block applink.instagram.com URLs (Universal Links) - try to extract post URL from page
              if (urlLower.contains('applink.instagram.com')) {
                print('Instagram Profile - Blocking applink URL, trying to extract post URL: $originalUrl');
                
                // Check if we have a captured post URL from JavaScript handler
                if (_capturedPostUrl != null) {
                  print('Instagram Profile - Using captured post URL: $_capturedPostUrl');
                  final capturedUrl = _capturedPostUrl!;
                  _capturedPostUrl = null; // Reset
                  Future.microtask(() {
                    controller.loadUrl(urlRequest: URLRequest(url: WebUri(capturedUrl)));
                  });
                  return NavigationActionPolicy.CANCEL;
                }
                
                // Try to extract post URL from last clicked element
                try {
                  final postUrl = await controller.evaluateJavascript(source: '''
                    (function() {
                      try {
                        // Use the exposed function to get post URL from last clicked element
                        if (window.getLastClickedPostUrl) {
                          const url = window.getLastClickedPostUrl();
                          if (url) return url;
                        }
                        
                        // Fallback: Get all post links in the page and find the most recently added/visible one
                        const posts = document.querySelectorAll('a[href*="/p/"], a[href*="/reel/"], a[href*="/tv/"]');
                        for (let post of posts) {
                          const href = post.href;
                          if (href && (href.includes('/p/') || href.includes('/reel/') || href.includes('/tv/'))) {
                            // Extract clean URL
                            let cleanUrl = href.split('?')[0];
                            if (!cleanUrl.startsWith('http')) {
                              cleanUrl = 'https://www.instagram.com' + (cleanUrl.startsWith('/') ? cleanUrl : '/' + cleanUrl);
                            }
                            return cleanUrl;
                          }
                        }
                        
                        // Check for post URLs in data attributes
                        const elements = document.querySelectorAll('[data-href*="/p/"], [data-href*="/reel/"], [data-href*="/tv/"]');
                        for (let el of elements) {
                          const dataHref = el.getAttribute('data-href') || el.getAttribute('href');
                          if (dataHref && (dataHref.includes('/p/') || dataHref.includes('/reel/') || dataHref.includes('/tv/'))) {
                            let cleanUrl = dataHref.split('?')[0];
                            if (!cleanUrl.startsWith('http')) {
                              cleanUrl = 'https://www.instagram.com' + (cleanUrl.startsWith('/') ? cleanUrl : '/' + cleanUrl);
                            }
                            return cleanUrl;
                          }
                        }
                        
                        return null;
                      } catch(e) {
                        console.error('Error extracting post URL:', e);
                        return null;
                      }
                    })();
                  ''');
                  
                  if (postUrl != null && postUrl.toString().isNotEmpty && postUrl.toString() != 'null') {
                    final extractedUrl = postUrl.toString().replaceAll('"', '').trim();
                    print('Instagram Profile - Extracted post URL from page: $extractedUrl');
                    Future.microtask(() {
                      controller.loadUrl(urlRequest: URLRequest(url: WebUri(extractedUrl)));
                    });
                  } else {
                    print('Instagram Profile - Could not extract post URL, staying on current page');
                  }
                } catch (e) {
                  print('Instagram Profile - Error extracting post URL: $e');
                }
                
                return NavigationActionPolicy.CANCEL;
              }
              
              // Block URLs with launch_app_store parameter
              if (urlLower.contains('launch_app_store=true')) {
                print('Instagram Profile - Blocking URL with launch_app_store: $originalUrl');
                return NavigationActionPolicy.CANCEL;
              }
              
              // Allow navigation to Instagram post URLs (p/, reel/, tv/)
              if (urlLower.contains('instagram.com') && 
                  (urlLower.contains('/p/') || 
                   urlLower.contains('/reel/') || 
                   urlLower.contains('/tv/') ||
                   urlLower.contains('/reels/'))) {
                print('Instagram Profile - Allowing navigation to post: $originalUrl');
                return NavigationActionPolicy.ALLOW;
              }
              
              // Block app scheme redirects and App Store URLs
              if (urlLower.startsWith('instagram://') ||
                  urlLower.startsWith('fb://') ||
                  urlLower.startsWith('fbapi://') ||
                  urlLower.contains('apps.apple.com') ||
                  urlLower.contains('itunes.apple.com') ||
                  urlLower.startsWith('itms://') ||
                  urlLower.startsWith('itms-apps://') ||
                  urlLower.contains('play.google.com/store') ||
                  urlLower.startsWith('market://')) {
                print('Instagram Profile - Blocking navigation to: $originalUrl');
                return NavigationActionPolicy.CANCEL;
              }
              
              // Check if we have a captured post URL
              if (_capturedPostUrl != null) {
                print('Instagram Profile - Loading captured post URL: $_capturedPostUrl');
                final capturedUrl = _capturedPostUrl!;
                _capturedPostUrl = null; // Reset
                Future.microtask(() {
                  controller.loadUrl(urlRequest: URLRequest(url: WebUri(capturedUrl)));
                });
                return NavigationActionPolicy.CANCEL;
              }
              
              // Allow other Instagram URLs
              if (urlLower.contains('instagram.com')) {
                print('Instagram Profile - Allowing navigation within Instagram: $originalUrl');
                return NavigationActionPolicy.ALLOW;
              }
              
              return NavigationActionPolicy.ALLOW;
            },
            onReceivedServerTrustAuthRequest: (controller, challenge) async {
              return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
            },
          ),
          if (isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
