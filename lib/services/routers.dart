import 'package:flutter/material.dart';
import 'package:todo_list/screen/add_todo.dart';
import 'package:todo_list/screen/landing.dart';
import 'package:todo_list/screen/splash.dart';
import 'package:todo_list/screen/todo.dart';

class Routers {
  static landing(AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      return LandingPage();
    } else {
      return SplashPage();
    }
  }

  static splash() {
    return SplashPage();
  }

  static generatedRoutes(settings) {
    List data = settings.name.split('/');
    if (data.length <= 1) return;
    if (data[1] == 'landing' && data[2] != null) {
      return MaterialPageRoute(builder: (context) {
        return LandingPage();
      });
    }
    if (data[1] == 'todo' && data[2] != null) {
      int id = int.tryParse(data[2]);
      return MaterialPageRoute(builder: (context) {
        return TodoPage(id);
      });
    }
    return MaterialPageRoute(builder: (context) {
      return LandingPage();
    });
  }

  static routes() {
    return <String, WidgetBuilder>{
      '/landing': (BuildContext context) => LandingPage(),
      '/add_todo': (BuildContext context) => AddTodoPage(),
    };
  }

  static Route unKnownRoute(RouteSettings settings) {
    return PageRouteBuilder(pageBuilder: (BuildContext context,
        Animation<double> animation, Animation<double> secondaryAnimation) {
      return LandingPage();
    });
  }
}
