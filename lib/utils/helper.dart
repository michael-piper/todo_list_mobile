import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:todo_list/utils/colors.dart';
import 'package:intl/intl.dart';

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

double percentage(num amount, num per, {divider: 100}) {
  return amount - ((amount / divider) * per);
}

enum StatusBarType { LIGHT, DEFAULT, TRANSPARENT }

class Helper {
  static final oCcy = new NumberFormat("#,##0.00", "en_US");

  static String stringifyBarcode(Map<String, dynamic> barcode) {
    String data = "";
    barcode.forEach((key, value) {
      if (value.runtimeType == "String") value = Uri.encodeComponent(value);
      data += " $key:$value:${value.runtimeType}";
    });
    return base64Encode(utf8.encode("cashcitycoin v:1$data"));
  }

  static Map<String, dynamic> parseBarcode(String barcode) {
    final Map<String, dynamic> data = Map();
    barcode = utf8.decode(base64Decode(barcode));
    if (barcode.indexOf("cashcitycoin") != 0) return null;
    List<String> barcodeString =
        barcode.substring(13, barcode.length).split(" ");
    barcodeString.forEach((element) {
      List<dynamic> value = element.split(":");
      if (value.length > 2) {
        try {
          if (value[2] == "num") {
            data[value[0]] = num.tryParse(value[1]);
          } else if (value[2] == "int") {
            data[value[0]] = int.tryParse(value[1]);
          } else if (value[2] == "double" || value[2] == "float") {
            data[value[0]] = double.tryParse(value[1]);
          } else if (value[2] == "bool") {
            data[value[0]] = int.tryParse(value[1]) as bool;
          } else {
            data[value[0]] = Uri.decodeComponent(value[1]);
          }
        } catch (e) {
          print(e);
        }
      } else if (value.length > 1) {
        data[value[0]] = Uri.decodeComponent(value[1]);
      } else if (value.length == 1) {
        data[value[0]] = null;
      }
    });
    return data;
  }

  static onEditDate(String e, TextEditingController controller) {
    try {
      e = e.replaceAll('-', '');
      final date = [];
      if (e.length > 8) {
        e = e.substring(0, 8);
      }

      if (e.length >= 6) {
        date.add(e.substring(0, 4));
        date.add(e.substring(4, 6));
        date.add(e.substring(6, e.length));
      } else if (e.length >= 4) {
        date.add(e.substring(0, 4));
        date.add(e.substring(4, e.length));
      } else {
        date.add(e.substring(0, e.length));
      }
      controller.text = date.join('-');
      if (e.length == 4 || e.length == 6) {
        controller.selection = TextSelection.fromPosition(TextPosition(
          offset: controller.text.length - 1,
          affinity: TextAffinity.upstream,
        ));
      } else {
        controller.selection = TextSelection.fromPosition(
          TextPosition(
            offset: controller.text.length,
            affinity: TextAffinity.upstream,
          ),
        );
      }
    } catch (e) {
      controller.text = '';
      controller.selection = TextSelection.fromPosition(
        TextPosition(
            offset: controller.text.length, affinity: TextAffinity.upstream),
      );
    }
  }

  static onEditAmount(String e, TextEditingController controller,
      {num min: 0}) {
    try {
      String amount = e.replaceAll(',', '').replaceAll('.', '');
      amount = amount.substring(0, amount.length - 2) +
          '.' +
          amount.substring(amount.length - 2, amount.length);

      if (num.tryParse(amount) < min) {
        throw Exception("amount less than min");
      }
      controller.text = Helper.oCcy.format(num.tryParse(amount));
      if (e.length == 4) {
        controller.selection = TextSelection.fromPosition(
          TextPosition(
            offset: controller.text.length - 1,
            affinity: TextAffinity.upstream,
          ),
        );
      } else {
        controller.selection = TextSelection.fromPosition(
          TextPosition(
            offset: controller.text.length,
            affinity: TextAffinity.upstream,
          ),
        );
      }
    } on Exception {
      controller.text =
          min == 0 || min == null ? "0.00" : Helper.oCcy.format(min);
      controller.selection = TextSelection.fromPosition(
        TextPosition(
          offset: controller.text.length,
          affinity: TextAffinity.upstream,
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  static changeStatusColor(Color color) async {
    try {
      await FlutterStatusbarcolor.setStatusBarColor(color, animate: true);
      if (color != Colors.white) {
        FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
      } else {
        FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
      }
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    }
  }

  static setStatusBarWhiteForeground(bool value) {
    try {
      FlutterStatusbarcolor.setStatusBarWhiteForeground(value);
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    }
  }

  static setNavigationBarWhiteForeground(bool value) {
    try {
      FlutterStatusbarcolor.setNavigationBarWhiteForeground(value);
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    }
  }

  static changeNavigationColor(Color color) async {
    try {
      await FlutterStatusbarcolor.setNavigationBarColor(color, animate: true);
      if (color != Colors.white) {
        FlutterStatusbarcolor.setNavigationBarWhiteForeground(true);
      } else {
        FlutterStatusbarcolor.setNavigationBarWhiteForeground(false);
      }
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    }
  }

  static changeStatusBar(StatusBarType type) {
    switch (type) {
      case StatusBarType.TRANSPARENT:
        changeStatusColor(Colors.transparent);
        break;
      case StatusBarType.LIGHT:
        changeStatusColor(liteColor);
        changeNavigationColor(liteColor);

        break;
      case StatusBarType.DEFAULT:
      default:
        changeStatusColor(primaryColor);
        changeNavigationColor(primaryColor);
        break;
    }
  }

  static String printDurationHours(Duration duration, {int len}) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0 || len == 6) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else if (duration.inMinutes > 0 || len == 4) {
      return "$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitSeconds";
    }
  }
}

const List<String> month = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December"
];
const List<String> short_month = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec"
];

isNull(value, [alt]) {
  if (value == null) {
    return (alt == null) ? true : alt;
  }
  return (alt == null) ? false : value;
}

class MpValidator {
  static input({String value, String name, String type, bool declare}) {
    validate(String value) {
      print(name);
      if (value.isEmpty) {
        return 'Please enter a valid ${isNull(name, isNull(type, 'value'))}';
      }
      return null;
    }

    if (declare == true) {
      return validate;
    }
    return validate(value);
  }
}

String myDate(DateTime _time) {
  if (_time == null) return '';
  String time = '${_time.day}';
  if (_time.day == 3) {
    time += "rd";
  } else if (_time.day == 2) {
    time += "nd";
  } else if (_time.day == 1) {
    time += "st";
  } else {
    time += "th";
  }
  time += ' ' + short_month[_time.month];
  time += ', ${_time.year}';
  return time;
}

List<T> map<T>(List list, Function handler) {
  List<T> result = [];
  for (var i = 0; i < list.length; i++) {
    result.add(handler(i, list[i]));
  }

  return result;
}

Widget colorMaker(
  int color, {
  bool active: false,
  double width: 8.0,
  double height: 8.0,
}) =>
    Container(
      padding: EdgeInsets.all(2),
      margin: EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(active == true ? color : 0x00000000),
        border: Border.all(
          color: active == true ? Colors.black12 : Colors.transparent,
          style: BorderStyle.solid,
        ),
      ),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(color),
          border: Border.all(
            color: Color(active == true ? color : 0x8A000000),
            style: BorderStyle.solid,
          ),
        ),
      ),
    );

const DIVIDER = SizedBox(
  height: 50.0,
);
const SMALL_DIVIDER = SizedBox(
  height: 15.0,
);
const screenPadding = const EdgeInsets.symmetric(horizontal: 16.0);
