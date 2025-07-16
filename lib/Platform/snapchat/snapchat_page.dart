import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:stay_connected/Platform/snapchat/snapchat_controller.dart';
import 'package:stay_connected/widget/custom_drwaer.dart';
import 'package:stay_connected/widget/icon_selector.dart';

class SnapchatPage extends StatelessWidget {
  const SnapchatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SnapchatController>(
      init: SnapchatController(""),
      builder: (controller) {
        return Scaffold(
          drawer: const CustomDrawer(),
          appBar: AppBar(
            title: Text('Snapchat Icons'),
            centerTitle: true,
            backgroundColor: Colors.yellow,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              final nameController = TextEditingController();

              Get.defaultDialog(
                title: 'Add Custom Icon',
                content: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Icon Name'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
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
                      child: const Text('Select Icon'),
                    ),
                  ],
                ),
                textConfirm: 'Cancel',
                onConfirm: () => Get.back(),
              );
            },
            child: const Icon(Icons.add),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Shared categories
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.sharedCategories.length,
                  itemBuilder: (context, index) {
                    final item = controller.sharedCategories[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.grey.shade100,
                        radius: 30,
                        child: item['icon']!.endsWith('.svg')
                            ? Image.asset(
                                item['icon']!,
                                width: 40,
                                height: 40,
                                color: Colors.grey.shade700,
                              )
                            : Image.asset(
                                item['icon']!,
                                width: 40,
                                height: 40,
                              ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1),

              /// Platform icons grid
              Expanded(
                child: GridView.builder(
                  itemCount:
                      controller.icons.length > 9 ? 9 : controller.icons.length,
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                  ),
                  itemBuilder: (context, index) {
                    final iconData = controller.icons.length > 9
                        ? controller.icons.sublist(0, 9)[index]
                        : controller.icons[index];
                    return GestureDetector(
                      onLongPress: () => controller.removeIcon(index),
                      child: CircleAvatar(
                        backgroundColor: Colors.grey.shade100,
                        radius: 30,
                        child: iconData['icon']!.endsWith('.svg')
                            ? Image.asset(
                                iconData['icon']!,
                                width: 40,
                                height: 40,
                                color: Colors.grey.shade700,
                              )
                            : Image.asset(
                                iconData['icon']!,
                                width: 40,
                                height: 40,
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 