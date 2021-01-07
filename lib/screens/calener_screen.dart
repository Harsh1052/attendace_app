import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  final String currentUserID;
  final String professorID;
  final String studentID;

  CalendarScreen(
      {this.professorID, @required this.currentUserID, this.studentID});
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _fireStore = FirebaseFirestore.instance;
  CalendarController _calendarController;
  Map<DateTime, List<dynamic>> _events;
  List<dynamic> _onSelectedDay;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _calendarController = CalendarController();
    _events = {};
    _onSelectedDay = [];
    addEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10.0),
              child: TableCalendar(
                events: _events,
                calendarController: _calendarController,
                initialCalendarFormat: CalendarFormat.month,
                builders: CalendarBuilders(
                  markersBuilder: (context, date, events, holiday) {
                    final children = <Widget>[];

                    if (events.isNotEmpty) {
                      children.add(
                          Positioned(child: _buildEventsmarker(date, events)));
                    }
                    return children;
                  },
                ),
                onDaySelected: (date, list, events) {
                  setState(() {
                    _onSelectedDay = list;
                  });
                },
              ),
            ),
            ..._onSelectedDay.map((e) => ListTile(
                  title: Text(
                    e,
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 20.0,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _calendarController.dispose();
  }

  _buildEventsmarker(DateTime, List events) {
    return Container(
      padding: EdgeInsets.all(3.0),
      decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
      child: Text(
        events.length.toString(),
        style: TextStyle(color: Colors.white, fontSize: 10.0),
      ),
    );
  }

  addEvents() async {
    if (widget.studentID == null) {
      var data = await _fireStore
          .collection("attendanceData")
          .where("professorID", isEqualTo: widget.professorID)
          .where("studentID", isEqualTo: widget.currentUserID)
          .get();
      setState(() {
        for (var d in data.docs) {
          if (d.data()["present"] == false) {
            Timestamp t = d.data()["date"];
            DateTime dt = t.toDate();
            _events[dt] = [
              "You did not attend ${d.data()["professorName"]}'s lecture on this day"
            ];
          }
        }
      });
    } else {
      var data = await _fireStore
          .collection("attendanceData")
          .where("professorID", isEqualTo: widget.currentUserID)
          .where("studentID", isEqualTo: widget.studentID)
          .get();
      for (var d in data.docs) {
        if (d.data()["present"] == false) {
          Timestamp t = d.data()["date"];
          DateTime dt = t.toDate();
          _events[dt] = [
            "This student did not attend ${d.data()["professorName"]}'s lecture on this day"
          ];
        }
      }
    }
  }
}
