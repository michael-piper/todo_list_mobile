import 'package:flutter/material.dart';
import 'package:todo_list/utils/colors.dart';
import 'package:todo_list/utils/helper.dart';

class SplashPage extends StatelessWidget {
  SplashPage() {
    Helper.changeStatusBar(StatusBarType.TRANSPARENT);
    Helper.changeNavigationColor(primaryColor);
    Helper.setStatusBarWhiteForeground(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(
            color: primaryColor,
            image: DecorationImage(
              image: AssetImage("assets/images/bootloader.png"),
              fit: BoxFit.fill,
            ),
          ),
          child: Center(
            child: SizedBox(
              width: 150,
              height: 150,
              child: Image(
                  image: AssetImage('assets/images/logo.png'),
                  width: 150,
                  height: 150),
            ),
          )),
    );
  }
}
