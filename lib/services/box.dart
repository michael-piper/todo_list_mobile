import 'package:hive/hive.dart';
import 'types.dart';
final settingsBox = Hive.box("settings");

final accountBox = Hive.box("account");

final todoListBox = Hive.box<Todo>("todo_list");