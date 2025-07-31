import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:stay_connected/Platform/instagram/instagram_webview_screen.dart';

class InstagramSearchDialog extends StatelessWidget {
  final String iconName;
  final String platformName;

  const InstagramSearchDialog({
    Key? key,
    required this.iconName,
    required this.platformName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();

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
              CupertinoIcons.search,
              color: CupertinoColors.systemBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Search for $iconName',
            style: const TextStyle(
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
              'Search and add friends to your category',
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: searchController,
              autofocus: true,
              placeholder: 'Enter name to search...',
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
            if (searchController.text.trim().isNotEmpty) {
              Navigator.of(context).pop();
              Get.to(() => InstagramWebviewScreen(
                    searchQuery: searchController.text.trim(),
                    iconName: iconName,
                    platformName: platformName,
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
