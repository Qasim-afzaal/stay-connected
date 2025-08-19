import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:stay_connected/Platform/shared/profile_webview_screen.dart';

class FacebookWebviewScreen extends StatelessWidget {
  final String searchQuery;
  final String iconName;
  final String platformName;

  const FacebookWebviewScreen({
    super.key,
    required this.searchQuery,
    required this.iconName,
    required this.platformName,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileWebViewScreen(
      platform: platformName,
      searchQuery: searchQuery,
      iconName: iconName,
    );
  }
}
