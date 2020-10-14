import 'package:flutter/material.dart';
import 'package:todo_list/utils/colors.dart';

class MyButton extends StatelessWidget {
  MyButton(
    this.text, {
    this.onPressed,
    this.type: 1,
    this.color = primaryColor,
    this.display = true,
  });

  final String text;
  final Function onPressed;
  final int type;
  final Color color;
  final bool display;

  @override
  Widget build(BuildContext context) {
    if (display != true) {
      return Container();
    }
    return MaterialButton(
      padding: EdgeInsets.symmetric(vertical: 15),
      color: type == 1 ? color : liteColor,
      onPressed: onPressed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(color: type == 1 ? primarySwatch : color),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            text,
            style: TextStyle(
              fontSize: 16.0,
              color: type == 1 ? primaryTextColor : color,
            ),
          ),
        ],
      ),
    );
  }
}
