import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'view_types.dart';

class EventView extends StatelessWidget {
  EventView({
    @required int this.year,
    @required int this.month,
    @required int this.day,
    @required ViewCallback this.switchViewCallback
  });

  final int year;
  final int month;
  final int day;
  final ViewCallback switchViewCallback;

  @override
  Widget build(BuildContext context) {
    Widget component = new Container(
      constraints: new BoxConstraints(),
      margin: new EdgeInsets.all(8.0),
      child: new Center(
        child: new Column(
          children: <Widget>[
            new Text('Day: ' + MonthNames[month]['long'] + ' $day, $year'),
            new Container(
              padding: new EdgeInsets.all(8.0),
              child: new RaisedButton(
                child: new Text('back to calendar'),
                onPressed: () {
                  switchViewCallback(
                    view: RenderableView.calendar
                  );
                }
              )
            )
          ]
        )
      )
    );

    return component;
  }
}