import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:stay_connected/home/home.dart';
import 'package:stay_connected/home/home_controller.dart';
import 'package:stay_connected/pages/about_page.dart';
import 'package:stay_connected/pages/tips_tricks_page.dart';
import 'package:stay_connected/routes/app_pages.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.put(HomeController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: theme.drawerTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: isDark ? Colors.black : null,
              image: isDark ? null : DecorationImage(
                image: AssetImage('assets/images/blue_moutain.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 25, // Keep your circle size
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding:
                        const EdgeInsets.all(6.0), // Adjust padding as needed
                    child: Image.asset(
                      isDark ? 'assets/images/iconnew_nbg.png' : 'assets/images/img_logo1_1.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Stay Connected',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Guest',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Image.asset(
              isDark ? 'assets/images/home.png' : 'assets/images/img_logo1_1.png',
              scale: 13,
            ),
            title: const Text("Home"),
            onTap: () {
              Navigator.pop(context);
              Get.offAll(() => const HomePage());
            },
          ),
          ...homeController.socialPlatforms.map((item) {
                final isTwitter = item['name'].toString().toLowerCase() == 'twitter' || item['name'].toString().toLowerCase() == 'x';
                final iconPath = isTwitter 
                    ? (isDark ? 'assets/images/x_dark.png' : 'assets/images/x_light.png')
                    : (item['icon'] as String?);
                return ListTile(
                leading: isDark && isTwitter
                    ? Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: iconPath != null
                            ? Image.asset(
                                iconPath,
                                height: 24,
                                width: 24,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.link,
                                  color: Colors.grey[300],
                                  size: 20,
                                ),
                              )
                            : Icon(
                                Icons.link,
                                color: Colors.grey[300],
                                size: 20,
                              ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: iconPath != null
                            ? Image.asset(
                                iconPath,
                                height: 32,
                                width: 32,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(Icons.link),
                              )
                            : const Icon(Icons.link),
                      ),
                title: Text(item['name']),
                onTap: () {
                  debugPrint(item["name"].toString());
                  Navigator.pop(context);
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
                    case "x":
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
                      Get.offNamed(Routes.FACEBOOK);
                      break;
                  }
                },
              );
            }),
          const Divider(),
          ListTile(
            leading: Image.asset(
              'assets/images/hints_180x180.png',
              width: 28,
              height: 28,
              fit: BoxFit.contain,
            ),
            title: const Text('Tips & Tricks'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const TipsTricksPage());
            },
          ),
          ListTile(
            leading: Image.asset(
              'assets/images/information.png',
              width: 28,
              height: 28,
              fit: BoxFit.contain,
            ),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const AboutPage());
            },
          ),
        ],
      ),
    );
  }
}
