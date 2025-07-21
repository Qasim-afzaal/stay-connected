import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IconSelector extends StatelessWidget {
  final Function(String iconPath, String iconName) onIconSelected;

  const IconSelector({
    Key? key,
    required this.onIconSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Predefined asset icons with names
    final List<Map<String, String>> availableIcons = [
      {'name': 'Home', 'path': 'assets/icons/home.svg'},
      {'name': 'Chat', 'path': 'assets/icons/chat.svg'},
      {'name': 'Settings', 'path': 'assets/icons/settings.svg'},
      {'name': 'Account', 'path': 'assets/icons/account_circle.svg'},
      {'name': 'Search', 'path': 'assets/icons/search.svg'},
      {'name': 'Add', 'path': 'assets/icons/add.svg'},
      {'name': 'Delete', 'path': 'assets/icons/delete.svg'},
      {'name': 'Bell', 'path': 'assets/icons/bell.png'},
      {'name': 'Mail', 'path': 'assets/icons/mail.png'},
      {'name': 'Pin', 'path': 'assets/icons/pin.png'},
      {'name': 'Logout', 'path': 'assets/icons/logout.png'},
      {'name': 'Headphone', 'path': 'assets/icons/headphone.svg'},
      {'name': 'Idea', 'path': 'assets/icons/idea.svg'},
      {'name': 'Fingerprint', 'path': 'assets/icons/fingerprint.svg'},
      {'name': 'Mic', 'path': 'assets/icons/mic.svg'},
      {'name': 'Send', 'path': 'assets/icons/send.svg'},
      {'name': 'Copy', 'path': 'assets/icons/copy.svg'},
      {'name': 'Upload', 'path': 'assets/icons/upload.svg'},
      {'name': 'Restart', 'path': 'assets/icons/restart.svg'},
      {'name': 'Check', 'path': 'assets/icons/check_outline.svg'},
      {'name': 'Stop', 'path': 'assets/icons/stop.svg'},
      {'name': 'Archived', 'path': 'assets/icons/archived.svg'},
      {'name': 'New Chat', 'path': 'assets/icons/newchat.svg'},
      {'name': 'Attachments', 'path': 'assets/icons/attachments.svg'},
      {'name': 'Dislike', 'path': 'assets/icons/dislike.svg'},
      {'name': 'Thumb Down', 'path': 'assets/icons/thumb_down.svg'},
      {'name': 'Voice Bar', 'path': 'assets/icons/voice_bar.png'},
      {'name': 'Delete All', 'path': 'assets/icons/delete_all.png'},
      {'name': 'Terms', 'path': 'assets/icons/terms.png'},
    ];

    return Dialog(
      child: Container(
        width: 300,
        height: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Icon',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: availableIcons.length,
                itemBuilder: (context, index) {
                  final icon = availableIcons[index];
                  return GestureDetector(
                    onTap: () {
                      onIconSelected(icon['path']!, icon['name']!);
                      Get.back();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Handle both SVG and PNG files
                          icon['path']!.endsWith('.svg')
                              ? Image.asset(
                                  icon['path']!,
                                  width: 32,
                                  height: 32,
                                  color: Colors.grey.shade700,
                                )
                              : Image.asset(
                                  icon['path']!,
                                  width: 32,
                                  height: 32,
                                ),
                          const SizedBox(height: 4),
                          Text(
                            icon['name']!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 