import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:stay_connected/Platform/reddit/reddit_controller.dart';
import 'package:stay_connected/Platform/reddit/reddit_icon_screen.dart';
import 'package:stay_connected/widget/custom_drwaer.dart';
import 'package:stay_connected/widget/icon_selector.dart';

class RedditPage extends StatelessWidget {
  RedditPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RedditController>(
      builder: (controller) {
        // Only show category icons (no profileUrl)
        final categoryIcons = controller.icons
            .where((icon) =>
                icon['profileUrl'] == null || icon['profileUrl']!.isEmpty)
            .toList();
        return Scaffold(
          drawer: const CustomDrawer(),
          appBar: AppBar(
            title: const Text('Reddit'),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
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
                            color: Colors.black,
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
                  icon: const Icon(Icons.check, color: Colors.black),
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
            decoration: const BoxDecoration(
              image: DecorationImage(
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
                  childAspectRatio: 0.8,
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
                              width: 32,
                              height: 32,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.add,
                                  size: 32,
                                  color: Colors.grey,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
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
                    child: Container(
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
                                        width: 32,
                                        height: 32,
                                        color: Colors.grey.shade700,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(
                                            Icons.favorite,
                                            size: 32,
                                            color: Colors.grey.shade700,
                                          );
                                        },
                                      )
                                    : Image.asset(
                                        iconData['icon']!,
                                        width: 32,
                                        height: 32,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(
                                            Icons.favorite,
                                            size: 32,
                                            color: Colors.grey.shade700,
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
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
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
    final nameController = TextEditingController();

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CupertinoIcons.add_circled,
                  color: CupertinoColors.systemOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Add Custom Icon',
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
                const Text(
                  'Create a new custom icon',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 16),
                CupertinoTextField(
                  controller: nameController,
                  autofocus: true,
                  placeholder: 'Enter icon name (max 10 chars)',
                  maxLength: 10,
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
                if (nameController.text.isNotEmpty) {
                  Navigator.of(context).pop();
                  showCupertinoDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: const Text('Select Icon'),
                        content: const Text(
                            'Choose an icon for your custom category'),
                        actions: [
                          CupertinoDialogAction(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          CupertinoDialogAction(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Get.dialog(
                                IconSelector(
                                  onIconSelected: (iconPath, iconName) {
                                    if (nameController.text.isNotEmpty) {
                                      controller.addIcon(
                                        nameController.text,
                                        iconPath,
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                            isDefaultAction: true,
                            child: const Text('Select'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              isDefaultAction: true,
              child: const Text(
                'Next',
                style: TextStyle(
                  color: CupertinoColors.systemOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showIconOptions(
      BuildContext context, RedditController controller, int index) {
    final iconData = controller.icons[index];
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(
                    context, controller, index, iconData['name']!);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                controller.removeIcon(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, RedditController controller,
      int index, String currentName) {
    final nameController = TextEditingController(text: currentName);

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CupertinoIcons.pencil,
                  color: CupertinoColors.systemOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Rename Icon',
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
                const Text(
                  'Update the icon name',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 16),
                CupertinoTextField(
                  controller: nameController,
                  autofocus: true,
                  placeholder: 'Enter icon name (max 10 chars)',
                  maxLength: 10,
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
                if (nameController.text.isNotEmpty) {
                  controller.renameIcon(index, nameController.text);
                  Navigator.of(context).pop();
                }
              },
              isDefaultAction: true,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: CupertinoColors.systemOrange,
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
