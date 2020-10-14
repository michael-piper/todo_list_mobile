import 'package:flutter/material.dart';
import 'package:todo_list/screen/main.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'services/adapters.dart';
import 'services/types.dart';
void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter<Todo>(TodoAdapter());
  await Hive.openBox("settings");
  await Hive.openBox<Todo>("todo_list");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return screen(context);
  }
}
