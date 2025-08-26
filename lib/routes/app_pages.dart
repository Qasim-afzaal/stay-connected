import 'package:get/get.dart';

import 'package:stay_connected/Platform/facebook/facebook_binding.dart';
import 'package:stay_connected/Platform/facebook/facebook_page.dart';
import 'package:stay_connected/Platform/instagram/instagram_binding.dart';
import 'package:stay_connected/Platform/instagram/instagram_page.dart';
import 'package:stay_connected/Platform/pinterest/pinterest_binding.dart';
import 'package:stay_connected/Platform/pinterest/pinterest_page.dart';
import 'package:stay_connected/Platform/reddit/reddit_binding.dart';
import 'package:stay_connected/Platform/reddit/reddit_page.dart';
import 'package:stay_connected/Platform/snapchat/snapchat_binding.dart';
import 'package:stay_connected/Platform/snapchat/snapchat_page.dart';
import 'package:stay_connected/Platform/tiktok/tiktok_binding.dart';
import 'package:stay_connected/Platform/tiktok/tiktok_page.dart';
import 'package:stay_connected/Platform/twitter/twitter_binding.dart';
import 'package:stay_connected/Platform/twitter/twitter_page.dart';
import 'package:stay_connected/Platform/youtube/youtube_binding.dart';
import 'package:stay_connected/Platform/youtube/youtube_page.dart';
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
    GetPage(
        name: _Paths.INSTAGRAM,
        page: () => InstagramPage(),
        binding: InstagramBinding()),
    GetPage(
        name: _Paths.YOUTUBE,
        page: () => YouTubePage(),
        binding: YouTubeBinding()),
    GetPage(
        name: _Paths.TWITTER,
        page: () => TwitterPage(),
        binding: TwitterBinding()),
    GetPage(
        name: _Paths.TIKTOK,
        page: () => TikTokPage(),
        binding: TikTokBinding()),
    GetPage(
        name: _Paths.REDDIT,
        page: () => RedditPage(),
        binding: RedditBinding()),
    GetPage(
        name: _Paths.SNAPCHAT,
        page: () => SnapchatPage(),
        binding: SnapchatBinding()),
    GetPage(
        name: _Paths.PINTEREST,
        page: () => PinterestPage(),
        binding: PinterestBinding()),
  ];
}
