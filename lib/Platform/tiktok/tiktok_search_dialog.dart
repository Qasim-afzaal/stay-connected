import 'package:flutter/cupertino.dart';

import 'package:get/get.dart';

import 'package:stay_connected/Platform/tiktok/tiktok_webview_screen.dart';

class TikTokSearchDialog extends StatelessWidget {
  final String iconName;
  final String platformName;

  const TikTokSearchDialog({
    super.key,
    required this.iconName,
    required this.platformName,
  });

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();

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
            'Search for $iconName',
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
              placeholder: 'Enter name to search...',
         
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
            if (searchController.text.trim().isNotEmpty) {
              Navigator.of(context).pop();
              Get.to(() => TikTokWebviewScreen(
                    platformName: platformName,
                    searchQuery: searchController.text.trim(),
                    iconName: iconName,
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
  }
}
