import 'dart:io';

import 'package:todo_list/services/box.dart';
import 'package:todo_list/services/calendar_client.dart';
import "package:path_provider/path_provider.dart";
import 'types.dart';

final CalendarClient calendarClient = CalendarClient();

addTodo(String title, String subtitle,
    {DateTime startTime, DateTime endTime, File image}) async {
  Todo todo = Todo(title, subtitle);
  if (startTime != null) {
    todo.startTime = startTime;
  } else {
    todo.startTime = DateTime.now();
  }
  if (endTime != null) {
    todo.endTime = endTime;
  } else {
    todo.endTime = DateTime.now().add(Duration(days: 1));
  }

  todo.updatedAt = DateTime.now();

  if (image != null) {
    String newPath = (await getApplicationDocumentsDirectory()).path +
        "/${todo.updatedAt.millisecondsSinceEpoch}" +
        (image.path.split(".")[1]);
    image.copy(newPath);

    todo.image = newPath;
  }
  todoListBox.add(todo);
  await calendarClient.insert(
    title,
    subtitle,
    startTime,
    endTime,
  );
  return true;
}

deleteTodo(id) async {
  await todoListBox.deleteAt(id);
  await todoListBox.compact();
  return true;
}

Future deleteAllTodoByKeys(List<int> keys) async {
  await todoListBox.deleteAll(keys);
  await todoListBox.compact();
  return true;
}

deleteAllTodo() async {
  await todoListBox.clear();
  await todoListBox.compact();
  return true;
}
