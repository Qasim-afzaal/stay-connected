import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:stay_connected/Platform/facebook/facebook_controller.dart';
import 'package:stay_connected/Platform/facebook/facebook_icon_screen.dart';
import 'package:stay_connected/widget/custom_drwaer.dart';
import 'package:stay_connected/widget/icon_selector.dart';

class FacebookPage extends StatelessWidget {
  FacebookPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FaceBookController>(
      builder: (controller) {
        return Scaffold(
          drawer: const CustomDrawer(),
          appBar: AppBar(
            title: const Text('Facebook'),
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
                image: AssetImage('assets/images/img_group_173.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                itemCount: () {
                  final categoryIcons = controller.icons
                      .where((icon) =>
                          icon['profileUrl'] == null ||
                          icon['profileUrl']!.isEmpty)
                      .toList();
                  int crossAxisCount = 4;
                  int iconsInLastRow = (categoryIcons.length) % crossAxisCount;
                  int placeholders = iconsInLastRow == 0
                      ? 0
                      : crossAxisCount - iconsInLastRow - 1;
                  return categoryIcons.length +
                      1 +
                      (placeholders > 0 ? placeholders : 0);
                }(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final categoryIcons = controller.icons
                      .where((icon) =>
                          icon['profileUrl'] == null ||
                          icon['profileUrl']!.isEmpty)
                      .toList();
                  int crossAxisCount = 4;
                  int iconsInLastRow = (categoryIcons.length) % crossAxisCount;
                  int placeholders = iconsInLastRow == 0
                      ? 0
                      : crossAxisCount - iconsInLastRow - 1;
                  int addButtonIndex = categoryIcons.length +
                      (placeholders > 0 ? placeholders : 0);

                  if (index < categoryIcons.length) {
                    final iconData = categoryIcons[index];
                    final isSelected = controller.selectedIcons.contains(index);
                    return GestureDetector(
                      onTap: () {
                        if (controller.isDeleteMode) {
                          controller.toggleIconSelection(index);
                        } else {
                          Get.to(() => FacebookIconScreen(
                                iconName: iconData['name']!,
                                platformName: 'Facebook',
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
                        // No background or border in delete mode, match TikTok
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  child: _buildIconWidget(iconData['icon']!),
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
                                    color:
                                        isSelected ? Colors.red : Colors.grey,
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
                  } else if (placeholders > 0 && index < addButtonIndex) {
                    // Placeholder for alignment before Add button
                    return const SizedBox.shrink();
                  } else if (index == addButtonIndex) {
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
                  } else {
                    // Placeholder for any extra slots (shouldn't be needed, but safe)
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconWidget(String iconPath) {
    if (iconPath.endsWith('.svg')) {
      return SvgPicture.asset(
        iconPath,
        width: 32,
        height: 32,
        colorFilter: ColorFilter.mode(Colors.grey.shade700, BlendMode.srcIn),
        placeholderBuilder: (context) => Icon(
          Icons.favorite,
          size: 32,
          color: Colors.grey.shade700,
        ),
      );
    } else {
      return Image.asset(
        iconPath,
        width: 32,
        height: 32,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.favorite,
            size: 32,
            color: Colors.grey.shade700,
          );
        },
      );
    }
  }

  void _showAddIconDialog(BuildContext context, FaceBookController controller) {
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
                  color: CupertinoColors.systemBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CupertinoIcons.add_circled,
                  color: CupertinoColors.systemBlue,
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
              child: const Text(
                'Select',
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

  void _showRenameDialog(BuildContext context, FaceBookController controller,
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
                  color: CupertinoColors.systemBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CupertinoIcons.pencil,
                  color: CupertinoColors.systemBlue,
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
}
