import 'dart:io';

import 'package:get/get.dart';

import 'package:stay_connected/routes/app_pages.dart';

class SplashController extends GetxController {
  // final SocketService _socketService = SocketService();
  // void handleNavigation() {
  //   final loginData = getStorageData.readLoginData();

  //   if (loginData.data?.location != null) {
  //     print(
  //         getStorageData.readLoginData().data?.location?.locationAddress ?? "");
  //     Get.offNamed(
  //       Routes.DASHBOARD,
  //       arguments: {HttpUtil.loginModel: loginData},
  //     );
  //   } else {
  //     Get.offNamed(Routes.LOGIN);
  //   }
  // }

  @override
  void onReady() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      Get.offNamed(Routes.HOME);
    });

    super.onReady();
  }

  // @override
  // void onInit() {
  //   getId();
  //   // _socketService.initializeSocket();

  //   super.onInit();
  // }

  // @override
  // void onClose() {
  //   // _socketService.dispose();
  //   super.onClose();
  // }

  // Future<String?> getId() async {
  //   var deviceInfo = DeviceInfoPlugin();
  //   if (Platform.isIOS) {
  //     var iosDeviceInfo = await deviceInfo.iosInfo;
  //     getStorageData.saveString(
  //         getStorageData.deviceId, iosDeviceInfo.identifierForVendor);
  //     return iosDeviceInfo.identifierForVendor;
  //   } else if (Platform.isAndroid) {
  //     var androidDeviceInfo = await deviceInfo.androidInfo;
  //     getStorageData.saveString(getStorageData.deviceId, androidDeviceInfo.id);
  //     return androidDeviceInfo.id;
  //   }
  //   return null;
  // }
}
