import 'package:flutter/material.dart';

import 'package:get/get_state_manager/src/simple/get_state.dart';

import 'splash_controller.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: SplashController(),
      builder: (controller) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
            ),
            child: Center(
              child: Image.asset(
                "assets/images/iconnew_nbg.png",
                scale: 4,
              ),
            ),
          ),
        );
      },
    );
  }
}
