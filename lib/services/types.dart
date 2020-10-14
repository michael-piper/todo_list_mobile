import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Todo {
  @HiveField(0)
  String title;
  @HiveField(1)
  String subtitle;
  @HiveField(2)
  bool active;
  @HiveField(3)
  DateTime startTime;
  @HiveField(4)
  DateTime endTime;
  @HiveField(5)
  DateTime updatedAt;
  @HiveField(6)
  String image;
  Todo(
    this.title,
    this.subtitle, {
    this.active = true,
    this.startTime,
    this.endTime,
    this.updatedAt,
  });
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}
