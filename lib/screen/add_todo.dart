import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_list/services/functions.dart';
import 'package:todo_list/services/my_button.dart';
import 'package:todo_list/utils/colors.dart';
import 'package:todo_list/utils/helper.dart';
import '../services/types.dart';

class AddTodoPage extends StatefulWidget {
  @override
  _AddTodoPageState createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final _formKey = GlobalKey<FormState>();
  final titleCtx = TextEditingController();
  final subtitleCtx = TextEditingController();
  DateTime endTime;
  DateTime startTime;
  String dropdownValue;
  File file;
  static const List<Choice> choices = const <Choice>[
    const Choice(title: 'Attach file', icon: Icons.attachment),
    const Choice(title: 'Attach picture', icon: Icons.image),
  ];

  _select(Choice choice) {
    if (choice.icon == Icons.attachment) {
      FilePicker.platform
          .pickFiles(
        type: FileType.image,
      )
          .then((FilePickerResult result) {
        if (result == null) {
          return;
        }
        setState(() {
          file = File(result.files.single.path);
        });
      });
    }
    if (choice.icon == Icons.image) {
      ImagePicker.pickImage(source: ImageSource.gallery).then((value) {
        setState(() {
          file = value;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: liteColor,
        elevation: 0,
        brightness: Brightness.dark,
        iconTheme: IconThemeData(color: liteTextColor),
        title: Text(
          "Add Todo",
          style: TextStyle(color: liteTextColor),
        ),
        actions: [
          PopupMenuButton<Choice>(
            onSelected: _select,
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                  value: choice,
                  child: Text(choice.title),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          alignment: Alignment.bottomCenter,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Container(
                padding: screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: Image(
                            key: UniqueKey(),
                            image: file != null
                                ? FileImage(
                                    file,
                                  )
                                : AssetImage(
                                    "assets/images/logo.png",
                                  ),
                          ),
                        ),
                      ],
                    ),
                    DIVIDER,
                    TextField(
                      controller: titleCtx,
                      key: Key("#title"),
                      decoration: InputDecoration(
                        labelText: 'Title',
                        suffixIcon: Icon(Icons.title),
                        labelStyle: TextStyle(
                          color: secondaryTextColor,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: noteColor),
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    SMALL_DIVIDER,
                    TextField(
                      controller: subtitleCtx,
                      key: Key("#subtitle"),
                      decoration: InputDecoration(
                        labelText: 'Subtitle',
                        suffixIcon: Icon(Icons.subject),
                        labelStyle: TextStyle(
                          color: secondaryTextColor,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: noteColor),
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      minLines: 4,
                      maxLines: 4,
                      keyboardType: TextInputType.text,
                    ),
                    SMALL_DIVIDER,
                    Text(
                      "Event Time",
                      style: TextStyle(fontSize: 18),
                    ),
                    SMALL_DIVIDER,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Checkbox(
                              value: startTime != null,
                              onChanged: (value) {
                                if (value) return addStartTime();
                                setState(() {
                                  startTime = null;
                                });
                              },
                            ),
                            Text("Start time."),
                          ],
                        ),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Checkbox(
                              value: endTime != null,
                              onChanged: (value) {
                                if (value) return addEndTime();
                                setState(() {
                                  endTime = null;
                                });
                              },
                            ),
                            Text("End time."),
                          ],
                        ),
                      ],
                    ),
                    SMALL_DIVIDER,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${startTime == null ? "" : startTime}"),
                        Text("${endTime == null ? "" : endTime}")
                      ],
                    ),
                    SMALL_DIVIDER,
                    MyButton(
                      "Add",
                      onPressed: () async {
                        if (await addTodo(
                          titleCtx.text,
                          subtitleCtx.text,
                          startTime: startTime,
                          endTime: endTime,
                          image: file,
                        )) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    SMALL_DIVIDER,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  addStartTime() {
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      minTime: DateTime.now(),
      maxTime: DateTime.now()..add(Duration(days: 365 * 400)),
      onChanged: (date) {
        print('change $date');
      },
      onConfirm: (date) {
        setState(() {
          this.startTime = date;
        });
      },
      currentTime: DateTime.now(),
      locale: LocaleType.en,
    );
  }

  addEndTime() {
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      minTime: DateTime.now(),
      maxTime: DateTime.now()..add(Duration(days: 365 * 400)),
      onChanged: (date) {
        print('change $date');
      },
      onConfirm: (date) {
        setState(() {
          this.endTime = date;
        });
      },
      currentTime: DateTime.now(),
      locale: LocaleType.en,
    );
  }
}
