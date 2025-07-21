import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:stay_connected/home/home.dart';
import 'package:stay_connected/home/home_controller.dart';
import 'package:stay_connected/routes/app_pages.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.put(HomeController());

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Row(
              children: [
                Icon(Icons.connect_without_contact,
                    size: 30, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'Stay Connected',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {
              Navigator.pop(context);
              Get.offAll(() => const HomePage());
            },
          ),
          ...homeController.socialPlatforms.map((item) => ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    item['icon'],
                    height: 24,
                    width: 24,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.link),
                  ),
                ),
                title: Text(item['name']),
                onTap: () {
                  print(item["name"]);
                  Navigator.pop(context);
                  
                  // Navigate to appropriate platform based on name
                  switch (item["name"].toString().toLowerCase()) {
                    case "facebook":
                      Get.offNamed(Routes.FACEBOOK);
                      break;
                    case "instagram":
                      Get.offNamed(Routes.INSTAGRAM);
                      break;
                    case "youtube":
                      Get.offNamed(Routes.YOUTUBE);
                      break;
                    case "twitter":
                      Get.offNamed(Routes.TWITTER);
                      break;
                    case "tiktok":
                      Get.offNamed(Routes.TIKTOK);
                      break;
                    case "reddit":
                      Get.offNamed(Routes.REDDIT);
                      break;
                    case "snapchat":
                      Get.offNamed(Routes.SNAPCHAT);
                      break;
                    case "pinterest":
                      Get.offNamed(Routes.PINTEREST);
                      break;
                    default:
                      // Fallback to Facebook if platform not found
                      Get.offNamed(Routes.FACEBOOK);
                      break;
                  }
                },
              )),
        ],
      ),
    );
  }
}
