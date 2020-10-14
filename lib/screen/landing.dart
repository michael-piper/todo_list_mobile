import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todo_list/services/box.dart' show todoListBox, settingsBox;
import 'package:todo_list/services/functions.dart';
import 'package:todo_list/utils/colors.dart';
import 'package:todo_list/utils/helper.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_list/widgets/please_wait.dart';

import '../services/types.dart';
import 'package:timeago/timeago.dart' as timeago;

class CItem {
  CItem(this.id, this.todo);

  final int id;
  final Todo todo;
}

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final List<int> todoToDelete = [];
  bool enableCheckbox = false;
  Map<DateTime, List<CItem>> _events = {};
  List<CItem> _selectedEvents = [];
  CalendarController _calendarController = CalendarController();
  final searchCtx = TextEditingController();
  List<int> searchResult;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Helper.setStatusBarWhiteForeground(false);
    Helper.changeNavigationColor(liteColor);
    final String view = settingsBox.get('todoview', defaultValue: "calendar");
    if (view == "calendar") {
      int id = 0;
      todoListBox.values.forEach((element) {
        if (_events[dateTine(element.startTime)] == null) {
          _events[dateTine(element.startTime)] = [];
        }
        _events[dateTine(element.startTime)].add(CItem(id, element));
        id++;
      });
      _loadSchedule(_events[dateTine(DateTime.now())]);
    }
  }

  openSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: liteColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              child: Wrap(
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: IconButton(
                      icon: Icon(Icons.minimize),
                      onPressed: () {},
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.person,
                      color: primaryColor,
                    ),
                    title: Text(
                      'Delete all task',
                      style: TextStyle(color: primaryColor),
                    ),
                    onTap: () {
                      deleteAll();
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.person_pin,
                      color: primaryColor,
                    ),
                    title: Text(
                      'Change view',
                      style: TextStyle(color: primaryColor),
                    ),
                    onTap: () {
                      final String view =
                          settingsBox.get('todoview', defaultValue: "calendar");
                      if (view == "list") {
                        settingsBox.put('todoview', "calendar");
                      } else {
                        settingsBox.put('todoview', "list");
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  delete(int id) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: liteColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Wrap(
              children: [
                Container(
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: Icon(Icons.minimize),
                    onPressed: () {},
                  ),
                ),
                ListTile(
                  title: Text("Confirm"),
                  subtitle: Text("Are you sure you want to delete this task?"),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        PleaseWait.open(context);
                        deleteTodo(id).then((e) {
                          PleaseWait.close(context);
                        });
                      },
                      child: Text("Yes"),
                    ),
                    FlatButton(
                      onPressed: Navigator.of(context).pop,
                      child: Text(
                        "No",
                        style: TextStyle(color: rejectColor),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  deleteAll() {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: liteColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Wrap(
              children: [
                Container(
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: Icon(Icons.minimize),
                    onPressed: () {},
                  ),
                ),
                ListTile(
                  title: Text("Confirm"),
                  subtitle:
                      Text("Are you sure you want to delete all this task?"),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        PleaseWait.open(context);
                        deleteAllTodo().then((e) {
                          PleaseWait.close(context);
                        });
                      },
                      child: Text("Yes"),
                    ),
                    FlatButton(
                      onPressed: Navigator.of(context).pop,
                      child: Text(
                        "No",
                        style: TextStyle(color: rejectColor),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  _deleteTodo() {
    PleaseWait.open(context);
    deleteAllTodoByKeys(todoToDelete).then((value) {
      setState(() {
        todoToDelete.clear();
      });
      PleaseWait.close(context);
    });
  }

  _enableCheckbox(bool state) {
    setState(() {
      enableCheckbox = state;
    });
  }

  _addCheckbox(int key) {
    if (todoToDelete.any((element) => element == key)) {
      setState(() {
        todoToDelete.remove(key);
      });

      return true;
    }
    setState(() {
      todoToDelete.add(key);
    });

    return false;
  }

  openSearch() {}

  _loadSchedule(List events) {
    setState(() {
      if (events == null) {
        return _selectedEvents = List<CItem>();
      }
      _selectedEvents = List<CItem>.from(events);
    });
  }

  void _onDaySelected(DateTime day, List events) {
    debugPrint('Callback: _onDaySelected');
    _loadSchedule(events);
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    debugPrint('Callback: _onVisibleDaysChanged');
  }

  Widget get buildEventList => Expanded(
        child: ListView(
          shrinkWrap: true,
          children: _selectedEvents
              .map<Widget>(
                (e) => ListTile(
                  onTap: () {
                    return Navigator.of(context).pushNamed("/todo/${e.id}");
                  },
                  title: Text(e.todo.title),
                  subtitle: Text(e.todo.subtitle),
                  trailing: Icon(Icons.chevron_right),
                ),
              )
              .toList(),
        ),
      );

  CalendarStyle get _calendarStyle => CalendarStyle(
        selectedColor: primaryColor,
        todayColor: primarySwatch,
        markersColor: secondaryColor,
        outsideDaysVisible: false,
      );

  HeaderStyle get _headerStyle => HeaderStyle(
        formatButtonTextStyle:
            TextStyle().copyWith(color: primaryTextColor, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
      );

  dateTine(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Widget get _calendar => ValueListenableBuilder(
        valueListenable: todoListBox.listenable(),
        builder: (context, Box<Todo> box, _) {
          _events.clear();
          int id = 0;
          box.values.forEach((element) {
            if (_events[dateTine(element.startTime)] == null) {
              _events[dateTine(element.startTime)] = [];
            }
            _events[dateTine(element.startTime)].add(CItem(id, element));
            id++;
          });

          return Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                            child: Text(
                          'Select Date',
                          style: TextStyle(color: noteColor),
                        ))
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    TableCalendar(
                      events: _events,
                      headerStyle: _headerStyle,
                      calendarStyle: _calendarStyle,
                      onDaySelected: _onDaySelected,
                      onVisibleDaysChanged: _onVisibleDaysChanged,
                      calendarController: _calendarController,
                    ),
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 20,
                        ),
                        Text('Select time slot'),
                        SizedBox(
                          width: 20,
                        ),
                        Icon(Icons.arrow_drop_down)
                      ],
                    ),
                    buildEventList,
                    SMALL_DIVIDER,
                  ],
                ),
              ),
            ),
          );
        },
      );

  Widget get list => Container(
        child: ValueListenableBuilder(
          valueListenable: todoListBox.listenable(),
          builder: (context, Box<Todo> box, _) {
            if (box.isEmpty) {
              return Center(
                child: Text("Empty todo"),
              );
            }
            search(value) {
              searchResult = [];
              setState(() {
                int id = 0;
                box.values.forEach((element) {
                  if (element.title.contains(value) ||
                      element.subtitle.contains(value)) {
                    searchResult.add(id);
                  }
                  id++;
                });
              });
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: searchCtx,
                    onChanged: search,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      hintText: "Search ........",
                      suffixIcon: IconButton(
                        icon: Icon(Icons.cancel),
                        onPressed: () {
                          searchCtx.clear();
                          setState(() {
                            searchResult = null;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: noteColor),
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ),
                SMALL_DIVIDER,
                Expanded(
                  child: ListView.builder(
                    itemCount:
                        searchResult == null ? box.length : searchResult.length,
                    padding: EdgeInsets.all(10),
                    itemBuilder: (context, listIndex) {
                      if (searchResult != null) {
                        listIndex = searchResult[listIndex];
                      }
                      Todo todo = box.getAt(listIndex);
                      return Card(
                        elevation: 7,
                        child: ListTile(
                          onTap: () {
                            if (!enableCheckbox) {
                              return Navigator.of(context)
                                  .pushNamed("/todo/$listIndex");
                            }
                            delete(listIndex);
                          },
                          onLongPress: () {
                            _enableCheckbox(!enableCheckbox);
                            if (!enableCheckbox) {
                              setState(() {
                                todoToDelete.clear();
                              });
                            }
                          },
                          leading: enableCheckbox
                              ? Checkbox(
                                  value: todoToDelete
                                      .any((element) => element == listIndex),
                                  onChanged: (value) => _addCheckbox(listIndex),
                                )
                              : null,
                          title: Text(todo.title),
                          subtitle: Text(
                            todo.subtitle,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                              "created:${timeago.format(todo.updatedAt, locale: 'en')}"),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: liteColor,
        elevation: 0,
        brightness: Brightness.dark,
        iconTheme: IconThemeData(color: liteTextColor),
        title: Text(
          "Todo List",
          style: TextStyle(color: liteTextColor),
        ),
        actions: [
          enableCheckbox
              ? InkWell(
                  child: Align(
                    alignment: Alignment.center,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          "Delete",
                          style: TextStyle(color: liteTextColor),
                        ),
                        Icon(Icons.delete),
                      ],
                    ),
                  ),
                  onTap: _deleteTodo,
                )
              : IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: openSettings,
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (enableCheckbox) {
            return _enableCheckbox(!enableCheckbox);
          }
          Navigator.of(context).pushNamed("/add_todo");
        },
        child: Icon(!enableCheckbox ? Icons.add : Icons.clear),
      ),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: settingsBox.listenable(keys: ['todoview']),
          builder: (context, Box box, _) {
            if (box.get("todoview", defaultValue: "calendar") == "calendar") {
              return _calendar;
            }
            return list;
          },
        ),
      ),
    );
  }
}
