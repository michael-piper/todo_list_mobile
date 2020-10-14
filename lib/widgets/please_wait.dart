import 'package:todo_list/utils/colors.dart';
import 'package:todo_list/utils/helper.dart';
import 'package:flutter/material.dart';

class PleaseWait extends StatelessWidget {
  PleaseWait([this.message]);

  final String message;
  static bool opened = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryTextColor,
      body: Container(
        color: primaryTextColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              isNull(message, ""),
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20,
            ),
            PleaseWait.loading(),
            const SizedBox(
              height: 10,
            ),
            Text("Please Wait"),
          ],
        ),
      ),
    );
  }

  static loading([double size = 50]) => Center(
        child: Padding(
          padding: EdgeInsets.all(size / 10),
          child: SizedBox(
            child: CircularProgressIndicator(),
            width: size,
            height: size,
          ),
        ),
      );

  static Future open(
    BuildContext context, {
    bool barrierDismissible = false,
    String message: "",
  }) {
    opened = true;
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: primaryTextColor,
      child: PleaseWait(message),
    );
  }

  static close(BuildContext context) {
    if (opened && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      opened = false;
    }
  }
}
