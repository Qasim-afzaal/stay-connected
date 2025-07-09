import 'package:get/get_navigation/src/routes/get_route.dart';

import 'package:stay_connected/Platform/facebook/facebook_binding.dart';
import 'package:stay_connected/Platform/facebook/facebook_page.dart';
import 'package:stay_connected/home/home.dart';
import 'package:stay_connected/home/home_binding.dart';
import 'package:stay_connected/splash/splash.dart';
import 'package:stay_connected/splash/splash_binding.dart';
import 'package:stay_connected/webview/webview_binding.dart';
import 'package:stay_connected/webview/webview_page.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
        name: _Paths.SPLASH,
        page: () => const SplashPage(),
        binding: SplashBinding()),
    GetPage(name: _Paths.HOME, page: () => HomePage(), binding: HomeBinding()),
    GetPage(
        name: _Paths.WEBVIEW,
        page: () => WebviewPage(),
        binding: WebviewBinding()),
    GetPage(
        name: _Paths.FACEBOOK,
        page: () => FacebookPage(),
        binding: FacebookBinding()),
  ];
}
