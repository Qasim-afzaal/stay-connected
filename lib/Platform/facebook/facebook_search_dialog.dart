import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:stay_connected/Platform/facebook/facebook_webview_screen.dart';

class FacebookSearchDialog extends StatelessWidget {
  final String iconName;
  final String platformName;

  const FacebookSearchDialog({
    super.key,
    required this.iconName,
    required this.platformName,
  });

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();

    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Search for $iconName',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                
                hintText: 'Enter name to search...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (searchController.text.isNotEmpty) {
                      Get.back();
                      Get.to(() => FacebookWebviewScreen(
                            searchQuery: searchController.text,
                            iconName: iconName,
                            platformName: platformName,
                          ));
                    }
                  },
                  child: const Text('Go'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
