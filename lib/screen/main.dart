import 'dart:io';
import 'package:flutter/material.dart';
import 'package:todo_list/utils/colors.dart';
import 'package:todo_list/services/routers.dart';


Widget screen(context) {
  if (Platform.isAndroid || Platform.isIOS) {
    return buildScreen(context);
  } else {
    return Routers.splash();
  }
}

buildScreen(context) {
  final navigatorKey = GlobalKey<NavigatorState>();
  return MaterialApp(
    title: 'Todo List',
    navigatorKey: navigatorKey,
    theme: ThemeData(
      // This is the theme of your application.
      primarySwatch: primarySwatch,
      primaryColor: primaryColor,
      backgroundColor: primaryTextColor,
      appBarTheme: AppBarTheme(
          color: primaryColor,
          brightness: Brightness.light,
          iconTheme: IconThemeData(color: primaryTextColor)),
      bottomAppBarTheme: BottomAppBarTheme(
        color: primaryColor,
      ),
    ),
    home: FutureBuilder(
      future: Future.wait([
        Future.delayed(Duration(seconds: 1), () => true),
      ]),
      builder: (context, AsyncSnapshot snapshot) {
        return Routers.landing(snapshot);
      },
    ),
    onGenerateRoute: (settings) {
      return Routers.generatedRoutes(settings);
    },
    onUnknownRoute: Routers.unKnownRoute,
    routes: Routers.routes(),
  );
}
