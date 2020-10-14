import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_list/services/box.dart' show todoListBox;
import 'package:todo_list/utils/colors.dart';
import 'package:todo_list/utils/helper.dart';
import '../services/types.dart';

class TodoPage extends StatefulWidget {
  TodoPage(this.id);

  final int id;

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  bool editing = false;
  final _formKey = GlobalKey<FormState>();
  final titleCtx = TextEditingController();
  final subtitleCtx = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  _editing(bool state) {
    setState(() {
      editing = state;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Helper.changeNavigationColor(primaryColor);
  }

  void saveOrEdit(Todo todo) {
    if (editing != true) {
      return _editing(!editing);
    }

    if (todo.title == titleCtx.text && todo.subtitle == subtitleCtx.text) {
      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text("Nothing to update.")));
    }
    todo.title = titleCtx.text;
    todo.subtitle = subtitleCtx.text;
    todo.updatedAt = DateTime.now();
    todoListBox.putAt(widget.id, todo);

    _editing(false);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: todoListBox.listenable(keys: [widget.id]),
      builder: (ctx, Box<Todo> box, _) {
        Todo todo = box.getAt(widget.id);
        if (todo == null) {
          return Center(
            child: Container(
              child: Text("Todo might have been delete"),
            ),
          );
        }

        titleCtx.text = todo.title;
        subtitleCtx.text = todo.subtitle;
        return WillPopScope(
          child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              brightness: Brightness.light,
              title: Text("Todo"),
              actions: [
                InkWell(
                  child: Align(
                    alignment: Alignment.center,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          editing ? "Save" : "Edit",
                        ),
                        Icon(editing ? Icons.save : Icons.edit),
                      ],
                    ),
                  ),
                  onTap: () => saveOrEdit(todo),
                ),
                SizedBox(
                  width: 20,
                ),
              ],
            ),
            body: SafeArea(
              child: Card(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  padding: screenPadding,
                  child: SingleChildScrollView(
                    child: editing
                        ? Form(
                            key: _formKey,
                            child: Container(
                              padding: screenPadding,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
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
                                        borderSide:
                                            BorderSide(color: noteColor),
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
                                        borderSide:
                                            BorderSide(color: noteColor),
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                    ),
                                    minLines: 4,
                                    maxLines: 4,
                                    keyboardType: TextInputType.text,
                                  ),
                                  SMALL_DIVIDER,
                                  SMALL_DIVIDER,
                                ],
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text("Title"),
                                subtitle: Text(todo.title),
                              ),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text("Description"),
                                subtitle: Text(todo.subtitle),
                              ),
                              Text(
                                "Event Time",
                                style: TextStyle(fontSize: 18),
                              ),
                              SMALL_DIVIDER,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text("Start time."),
                                    ],
                                  ),
                                  Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text("End time."),
                                    ],
                                  ),
                                ],
                              ),
                              SMALL_DIVIDER,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      "${todo.startTime == null ? "" : todo.startTime}"),
                                  Text(
                                      "${todo.endTime == null ? "" : todo.endTime}")
                                ],
                              ),
                              SMALL_DIVIDER,
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
          onWillPop: () async {
            Helper.changeNavigationColor(liteColor);
            return true;
          },
        );
      },
    );
  }
}
