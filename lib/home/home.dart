import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:stay_connected/home/home_controller.dart';
import 'package:stay_connected/routes/app_pages.dart';
import 'package:stay_connected/util/util.dart';
import 'package:stay_connected/webview/webview_binding.dart';
import 'package:stay_connected/webview/webview_page.dart';
import 'package:stay_connected/widget/custom_drwaer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          drawer: const CustomDrawer(),
          appBar: AppBar(
            title: const Text('Stay Connected'),
            centerTitle: true,
            backgroundColor: Colors.blue,
          ),
          body: Padding(
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
                    print(
                      item['name'],
                    );
                    Get.toNamed(Routes.FACEBOOK, arguments: {
                      HttpUtil.name: item['name'],
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.network(
                        item['icon'],
                        height: 40,
                        width: 40,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.link),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
