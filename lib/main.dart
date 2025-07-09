import 'package:flutter/widgets.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:sizer/sizer.dart';

import 'package:stay_connected/routes/app_pages.dart';

void main() async {
//  Get.lazyPut<SocketService>(() => SocketService(), fenix: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          // theme: ThemeLight().theme,
          builder: EasyLoading.init(),
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
        ),
      ),
    );
  }
}
