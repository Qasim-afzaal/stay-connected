import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:stay_connected/Platform/facebook/facebook_controller.dart';
import 'package:stay_connected/widget/custom_drwaer.dart';

class FacebookPage extends StatelessWidget {
  const FacebookPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FaceBookController>(
      init: FaceBookController(""),
      builder: (controller) {
        return Scaffold(
          drawer: const CustomDrawer(),
          appBar: AppBar(
            title: Text('Facwbook Icons'),
            centerTitle: true,
            backgroundColor: Colors.blue,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              final nameController = TextEditingController();
              final iconController = TextEditingController();

              Get.defaultDialog(
                title: 'Add Icon',
                content: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: iconController,
                      decoration: const InputDecoration(labelText: 'Icon URL'),
                    ),
                  ],
                ),
                textConfirm: 'Add',
                onConfirm: () {
                  if (nameController.text.isNotEmpty &&
                      iconController.text.isNotEmpty) {
                    controller.addIcon(
                      nameController.text,
                      iconController.text,
                    );
                    Get.back();
                  }
                },
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
                        backgroundImage: NetworkImage(item['icon']!),
                        radius: 30,
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
                        backgroundImage: NetworkImage(iconData['icon'] ?? ''),
                        radius: 30,
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
