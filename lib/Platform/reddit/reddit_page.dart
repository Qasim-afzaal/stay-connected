import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:stay_connected/Platform/reddit/reddit_controller.dart';
import 'package:stay_connected/Platform/reddit/reddit_icon_screen.dart';
import 'package:stay_connected/widget/custom_drwaer.dart';

class RedditPage extends StatelessWidget {
  RedditPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GetBuilder<RedditController>(
      builder: (controller) {
        final categoryIcons = controller.icons
            .where((icon) =>
                icon['profileUrl'] == null || icon['profileUrl']!.isEmpty)
            .toList();
        return Scaffold(
          drawer: const CustomDrawer(),
          appBar: AppBar(
            title: const Text('Reddit'),
            centerTitle: true,
            backgroundColor: theme.appBarTheme.backgroundColor,
            foregroundColor: theme.appBarTheme.foregroundColor,
            elevation: 0,
            actions: [
              IconButton(
                icon: controller.isDeleteMode
                    ? Image.asset(
                        'assets/images/deletepress.png',
                        width: 24,
                        height: 24,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 24,
                          );
                        },
                      )
                    : Image.asset(
                        'assets/images/deletepress.png',
                        width: 24,
                        height: 24,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.delete,
                            color: isDark ? Colors.grey[300] : Colors.black,
                            size: 24,
                          );
                        },
                      ),
                onPressed: () {
                  if (controller.isDeleteMode) {
                    controller.toggleDeleteMode();
                  } else {
                    controller.toggleDeleteMode();
                  }
                },
              ),
              if (controller.isDeleteMode &&
                  controller.selectedIcons.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.check, color: isDark ? Colors.grey[300] : Colors.black),
                  onPressed: () {
                    controller.deleteSelectedIcons();
                    Get.snackbar(
                      'Deleted',
                      'Selected icons have been deleted',
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 2),
                    );
                  },
                ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.black : null,
              image: isDark ? null : DecorationImage(
                image: AssetImage('assets/images/img_group_295.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: categoryIcons.length + 1,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  if (index == categoryIcons.length) {
                    return GestureDetector(
                      onTap: () => _showAddIconDialog(context, controller),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              'assets/images/platform_icons/add.png',
                              width: 50,
                              height: 50,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.add,
                                  size: 44,
                                  color: Colors.grey,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.grey[400] : Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final iconData = categoryIcons[index];
                  final isSelected = controller.selectedIcons.contains(index);

                  return GestureDetector(
                    onTap: () {
                      if (controller.isDeleteMode) {
                        controller.toggleIconSelection(index);
                      } else {
                        Get.to(() => RedditIconScreen(
                              iconName: iconData['name']!,
                              platformName: 'Reddit',
                            ));
                      }
                    },
                    onLongPress: () {
                      if (!controller.isDeleteMode) {
                        _showRenameDialog(
                            context, controller, index, iconData['name']!);
                      }
                    },
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              child: iconData['icon']!.endsWith('.svg')
                                  ? Image.asset(
                                      iconData['icon']!,
                                      width: 44,
                                      height: 44,
                                      color: isDark ? (Colors.grey[400] ?? Colors.grey.shade400) : Colors.grey.shade700,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(
                                          Icons.favorite,
                                          size: 32,
                                          color: isDark ? (Colors.grey[400] ?? Colors.grey.shade400) : Colors.grey.shade700,
                                        );
                                      },
                                    )
                                  : Image.asset(
                                      iconData['icon']!,
                                      width: 50,
                                      height: 50,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(
                                          Icons.favorite,
                                          size: 32,
                                          color: isDark ? (Colors.grey[400] ?? Colors.grey.shade400) : Colors.grey.shade700,
                                        );
                                      },
                                    ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                iconData['name']!,
                                style: TextStyle(
                                  fontSize: 11,
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
                        if (controller.isDeleteMode)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.red : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isSelected ? Icons.check : Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddIconDialog(BuildContext context, RedditController controller) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final nameController = TextEditingController();
    final List<Map<String, String>> availableIcons = [
      {'name': 'Food', 'path': 'assets/images/platform_icons/img_food_12.png'},
      {'name': 'Health', 'path': 'assets/images/platform_icons/health.png'},
      {
        'name': 'Photos',
        'path': 'assets/images/platform_icons/img_photo_1.png'
      },
      {'name': 'Music', 'path': 'assets/images/platform_icons/img_music_1.png'},
      {'name': 'Pets', 'path': 'assets/images/platform_icons/img_pets_1.png'},
      {
        'name': 'Games',
        'path': 'assets/images/platform_icons/img_gamepad_1.png'
      },
      {
        'name': 'Entertainment',
        'path': 'assets/images/platform_icons/ic_entertainment.png'
      },
      {'name': 'Auto', 'path': 'assets/images/platform_icons/auto.png'},
      {'name': 'Fashion', 'path': 'assets/images/platform_icons/fashion.png'},
      {
        'name': 'Desserts',
        'path': 'assets/images/platform_icons/img_desserts_1_64x64.png'
      },
      {
        'name': 'Favorites',
        'path': 'assets/images/platform_icons/img_favorite_1.png'
      },
      {
        'name': 'Fitness',
        'path': 'assets/images/platform_icons/img_fitness_1.png'
      },
      {
        'name': 'Travel',
        'path': 'assets/images/platform_icons/img_travel_1.png'
      },
      {'name': 'News', 'path': 'assets/images/platform_icons/news.png'},
      {'name': 'Cupid', 'path': 'assets/images/custom_icons/cupid_1.png'},
      {'name': 'Garden', 'path': 'assets/images/custom_icons/garden_3.png'},
      {'name': 'Heart', 'path': 'assets/images/custom_icons/heart_2.png'},
      {'name': 'Heart 2', 'path': 'assets/images/custom_icons/heart_3.png'},
      {
        'name': 'Lifestyle',
        'path': 'assets/images/custom_icons/lifestyle_1.png'
      },
      {'name': 'Plane', 'path': 'assets/images/custom_icons/plane_5.png'},
      {'name': 'Recipe', 'path': 'assets/images/custom_icons/recipe_3.png'},
      {
        'name': 'Recipe Book',
        'path': 'assets/images/custom_icons/recipe_book.png'
      },
      {'name': 'Reel', 'path': 'assets/images/custom_icons/reel_2.png'},
      {'name': 'Rest', 'path': 'assets/images/custom_icons/rest_2.png'},
      {'name': 'Rest 2', 'path': 'assets/images/custom_icons/rest_3.png'},
      {'name': 'Tele', 'path': 'assets/images/custom_icons/tele_1.png'},
      {
        'name': 'Checkmark',
        'path': 'assets/images/custom_icons/checkmark_blue.png'
      },
      {
        'name': 'Blue Apron',
        'path': 'assets/images/custom_icons/blue_apron.png'
      },
      {'name': 'Circle', 'path': 'assets/images/custom_icons/circle_2.png'},
      {'name': 'Play', 'path': 'assets/images/custom_icons/play.png'},
      {'name': 'Circle 2', 'path': 'assets/images/custom_icons/circle.png'},
      {'name': 'Square', 'path': 'assets/images/custom_icons/square.png'},
      {'name': 'Money', 'path': 'assets/images/custom_icons/money.png'},
      {'name': 'Twitter', 'path': 'assets/images/custom_icons/twitter.png'},
      {'name': 'Tick Mark', 'path': 'assets/images/custom_icons/tick_mark.png'},
      {'name': 'Folder', 'path': 'assets/images/custom_icons/folder.png'},
      {'name': 'Correct', 'path': 'assets/images/custom_icons/correct.png'},
      {
        'name': 'Egg Decoration',
        'path': 'assets/images/custom_icons/egg_decoration.png'
      },
      {
        'name': 'Easter Egg',
        'path': 'assets/images/custom_icons/easter_egg.png'
      },
      {
        'name': 'Easter Day',
        'path': 'assets/images/custom_icons/easter_day.png'
      },
      {
        'name': 'Electric Kettle',
        'path': 'assets/images/custom_icons/electric_kettle.png'
      },
      {'name': 'Necklace', 'path': 'assets/images/custom_icons/necklace.png'},
      {
        'name': 'Viennese Coffee',
        'path': 'assets/images/custom_icons/viennese_coffee.png'
      },
      {'name': 'Dislike', 'path': 'assets/images/custom_icons/dislike.png'},
      {
        'name': 'Favorite Chart',
        'path': 'assets/images/custom_icons/favorite_chart.png'
      },
      {'name': 'Koran', 'path': 'assets/images/custom_icons/koran.png'},
      {'name': 'Pets', 'path': 'assets/images/custom_icons/img_pets_12.png'},
      {'name': 'Add', 'path': 'assets/images/platform_icons/add.png'},
    ];
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        bool showAllIcons = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return CupertinoAlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 240,
                    child: CupertinoTextField(
                      controller: nameController,
                      autofocus: true,
                      placeholder: 'Icon name',
                      placeholderStyle: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                      // maxLength: 10,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey[300] : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!showAllIcons) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        final icon = availableIcons[i];
                        return GestureDetector(
                          onTap: () {
                            if (nameController.text.isNotEmpty) {
                              Navigator.of(context).pop();
                              controller.addIcon(
                                nameController.text,
                                icon['path']!,
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Image.asset(
                              icon['path']!,
                              width: 40,
                              height: 40,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(CupertinoIcons.photo, size: 32),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minSize: 28,
                      child: Text(
                        'See more',
                        style: TextStyle(color: isDark ? Colors.blue[300] : Colors.blue),
                      ),
                      onPressed: () {
                        setState(() {
                          showAllIcons = true;
                        });
                      },
                    ),
                  ] else ...[
                    SizedBox(
                      height: 300,
                      width: 300,
                      child: GridView.builder(
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: availableIcons.length,
                        itemBuilder: (context, index) {
                          final icon = availableIcons[index];
                          return GestureDetector(
                            onTap: () {
                              if (nameController.text.isNotEmpty) {
                                Navigator.of(context).pop();
                                controller.addIcon(
                                  nameController.text,
                                  icon['path']!,
                                );
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey[800] : CupertinoColors.systemGrey6,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark ? (Colors.grey[700] ?? Colors.grey.shade700) : CupertinoColors.systemGrey4,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Image.asset(
                                  icon['path']!,
                                  width: 32,
                                  height: 32,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(CupertinoIcons.photo, size: 32),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRenameDialog(BuildContext context, RedditController controller,
      int index, String currentName) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final nameController = TextEditingController(text: currentName);

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          content: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SizedBox(
              width: 240,
              child: CupertinoTextField(
                controller: nameController,
                autofocus: true,
                placeholder: 'Rename icon',
                placeholderStyle: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
                // maxLength: 10,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[300] : Colors.black,
                ),
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black),
              ),
            ),
            CupertinoDialogAction(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  controller.renameIcon(index, nameController.text);
                  Navigator.of(context).pop();
                }
              },
              isDefaultAction: true,
              child: Text(
                'OK',
                style: TextStyle(color: isDark ? Colors.blue[300] : Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }
}
