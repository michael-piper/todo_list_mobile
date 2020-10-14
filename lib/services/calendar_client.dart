import 'dart:developer' show log;
import 'dart:io' show Platform;
import "package:googleapis_auth/auth_io.dart";
import 'package:googleapis/calendar/v3.dart';
import 'package:url_launcher/url_launcher.dart';

class CalendarClient {
  static const _scopes = const [CalendarApi.CalendarScope];

  insert(title, subtitle, startTime, endTime) async {
    var _clientID;
    if (Platform.isAndroid) {
      _clientID = new ClientId(
        "265472300504-8s9g5p50eqn2ri96lapblfog3nb2usgk.apps.googleusercontent.com",
        "",
      );
    } else if (Platform.isIOS) {
      _clientID = new ClientId(
        "265472300504-ao24sa549o9acnoa93cobogqhgoe221l.apps.googleusercontent.com",
        "",
      );
    }

    clientViaUserConsent(_clientID, _scopes, prompt).then((AuthClient client) {
      var calendar = CalendarApi(client);
      calendar.calendarList.list().then((value) => print("VAL________$value"));

      String calendarId = "primary";
      Event event = Event(); // Create object of event

      event.summary = title;
      event.description = subtitle;
      EventDateTime start = new EventDateTime();
      start.dateTime = startTime;
      start.timeZone = "GMT+01:00";
      event.start = start;

      EventDateTime end = new EventDateTime();
      end.timeZone = "GMT+01:00";
      end.dateTime = endTime;
      event.end = end;
      try {
        return calendar.events.insert(event, calendarId).then((value) {
          print("ADDEDDD_________________${value.status}");
          if (value.status == "confirmed") {
            log('Event added in google calendar');
          } else {
            log("Unable to add event in google calendar");
          }
          return value;
        });
      } catch (e) {
        log('Error creating event $e');
      }
    });
  }

  void prompt(String url) async {
    print("Please go to the following URL and grant access:");
    print("  => $url");
    print("");

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
