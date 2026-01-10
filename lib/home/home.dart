import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:stay_connected/home/home_controller.dart';
import 'package:stay_connected/routes/app_pages.dart';
import 'package:stay_connected/widget/custom_drwaer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (HomeController controller) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        return Scaffold(
          drawer: const CustomDrawer(),
          appBar: AppBar(
            title: const Text('Stay Connected'),
            centerTitle: true,
            backgroundColor: isDark ? theme.appBarTheme.backgroundColor : Colors.white,
            foregroundColor: isDark ? theme.appBarTheme.foregroundColor : Colors.black,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Divider(
                height: 1,
                thickness: 1,
                color: isDark ? Colors.grey[800] : Colors.grey[300],
              ),
            ),
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: isDark 
                    ? Container(color: Colors.black)
                    : Image.asset(
                        'assets/images/img_group_173.jpg',
                        fit: BoxFit.cover,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: GridView.builder(
                  itemCount: controller.socialPlatforms.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 2,
                  ),
                  itemBuilder: (context, index) {
                    final item = controller.socialPlatforms[index];
                    return GestureDetector(
                      onTap: () {
                        print(item['name']);
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
                          case "tumblr":
                            // Add navigation if needed
                            break;
                          default:
                            Get.offNamed(Routes.FACEBOOK);
                            break;
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark 
                              ? Colors.grey.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: isDark 
                                ? Colors.grey[800]
                                : Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Image.asset(
                            item['icon'],
                            height: 70,
                            width: 70,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                Icon(Icons.link, color: isDark ? Colors.grey[300] : Colors.black),
                          ),
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
