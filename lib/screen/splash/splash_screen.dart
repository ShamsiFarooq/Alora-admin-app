import 'package:alora_admin/screen/bottomnav/bottom_nav_bar.dart';
import 'package:alora_admin/screen/requirement/requirement.dart';
import 'package:alora_admin/style/constant.dart';
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

import 'splash_functions.dart';

class ScreenSplash extends StatelessWidget {
  const ScreenSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedSplashScreen(
        splash: logoImage(),
        duration: 3000,
        nextScreen: BottomNavBar(),
        splashTransition: SplashTransition.fadeTransition,
        backgroundColor: color2,
      ),
    );
  }
}
