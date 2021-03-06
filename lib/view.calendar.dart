import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:calendar/core.dart';

class CalendarView extends StatelessWidget {
  CalendarView({
    @required int this.year,
    @required int this.month,
    @required int this.day,
    @required List<CalendarEvent> this.events,
    @required ViewCallback this.switchViewCallback,
    @required DataRefreshCallback this.refreshCallback,
    bool this.internalError: false
  });

  factory CalendarView.error({
    @required int year,
    @required int month,
    @required int day,
    @required DataRefreshCallback refreshCallback
  }) {
    void _noopCallback({ RenderableView view, Day selectedDay, CalendarEvent selectedEvent }) {}
    return new CalendarView(
      year: year,
      month: month,
      day: day,
      events: null,
      switchViewCallback: _noopCallback,
      refreshCallback: refreshCallback,
      internalError: true
    );
  }

  // VARIABLES
  final int year;
  final int month;
  final int day;
  final List<CalendarEvent> events;
  final ViewCallback switchViewCallback;
  final DataRefreshCallback refreshCallback;
  final bool internalError;

  // FUNCTIONS
  List<Day> _attachEvents(List<Day> days, List<CalendarEvent> events) {
    days.forEach((day) {
      events.forEach((event) {
        if (event.day == day.date && event.month == month && event.year == year) {
          day.addEvent(event);
        }
      });
      if (day.hasEvents) {
        day.addTapEventHandler(handler: switchViewCallback);
      }
    });
    return days;
  }

  List<Day> _generateMonthDays({ @required DateTime firstDay, @required DateTime lastDay }) {
    List<Day> days = <Day>[];
    for (int i = firstDay.day; i <= lastDay.day; i++) {
      if (i == day) {
        days.add(new Day(date: i, today: true));
      } else {
        days.add(new Day(date: i, today: false));
      }
    }
    if (!internalError) {
      return _attachEvents(days, events);
    } else {
      return days;
    }

  }

  List<Day> _generateMonthPadding({ DateTime firstDay, DateTime lastDay }) {
    List<Day> days = <Day>[];
    if (firstDay != null) {
      // INFO: build month padding - beginning
      var firstWeekday = firstDay.weekday;
      DateTime lastDayPrevMonth = new DateTime(year, month, 0);
      if (firstWeekday < 7) { // ignore if sunday (no padding needed)
        for (var i = 0; i < firstWeekday; i++) {
          days.insert(0, new Day(date: lastDayPrevMonth.day - i, today: false));
        }
      }
    } else if (lastDay != null) {
      // INFO: build month padding - ending
      var lastWeekday = lastDay.weekday;
      DateTime firstDayNextMonth = new DateTime(year, month + 1, 1);
      var remainingDays = (6 - lastWeekday == -1) ? 6 : (6 - lastWeekday);
      for (var i = 0; i < remainingDays; i++) {
        days.add(new Day(date: firstDayNextMonth.day + i, today: false));
      }
    }
    return days;
  }

  Widget _generateCalendarViewFooter(BuildContext context) {
    Widget component = new Container(
      decoration: new BoxDecoration(
        backgroundColor: Theme.of(context).accentColor
      ),
      child: new SizedBox(
        height: 48.0,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            new IconButton(
              size: 36.0,
              icon: new Icon(Icons.refresh, size: 36.0),
              onPressed: () {
                refreshCallback();
              },
              tooltip: 'Refresh events'
            )
          ]
        )
      )
    );
    return component;
  }

  List<Week> _generateMonthWeeks({ @required List<Day> monthDays }){
    List<Week> monthWeeks = new List<Week>();
    for (var weeknum = 0; weeknum < (monthDays.length / 7); weeknum++) {
      List<Day> weekDays = new List<Day>();
      for (var weekday = (weeknum * 7); weekday < (weeknum * 7) + 7; weekday++) {
        weekDays.add(monthDays[weekday]);
      }
      monthWeeks.add(new Week(days: weekDays));
    }
    return monthWeeks;
  }

  @override
  Widget build(BuildContext context) {
    DateTime _firstDay = new DateTime(year, month, 1);
    DateTime _lastDay = new DateTime(year, month + 1, 0);
    List<Day> monthDays = _generateMonthDays(firstDay: _firstDay, lastDay: _lastDay);
    monthDays.insertAll(0, _generateMonthPadding(firstDay: _firstDay));
    monthDays.addAll(_generateMonthPadding(lastDay: _lastDay));
    List<Week> monthWeeks = _generateMonthWeeks(monthDays: monthDays);

    Widget component = new Container(
      constraints: new BoxConstraints(),
      child: new Column(
        children: <Widget>[
          new CalendarViewHeader(monthName: MonthNames[month - 1]['long']),
          new Month(year: year, month: month, weeks: monthWeeks),
          _generateCalendarViewFooter(context)
        ]
      )
    );
    return component;
  }
}

class CalendarViewHeader extends StatelessWidget {
  CalendarViewHeader({ @required String this.monthName });

  final String monthName;

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 40.0,
      margin: new EdgeInsets.only(top: 5.0, bottom: 10.0),
      child: new Align(
        alignment: FractionalOffset.center,
        child: new Text(monthName)
      )
    );
  }
}

class CalendarViewEventIcon extends StatelessWidget {
  CalendarViewEventIcon({
    @required Color this.bgColor
  });

  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 5.0,
      width: 5.0,
      margin: new EdgeInsets.all(0.5),
      decoration: new BoxDecoration(
        backgroundColor: bgColor
      )
    );
  }
}

class CalendarViewEventIconRow extends StatelessWidget {
  CalendarViewEventIconRow({ @required List<CalendarViewEventIcon> this.eventIcons });
  List<CalendarViewEventIcon> eventIcons;

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: eventIcons
    );
  }
}