import 'package:attendace_app/wigets/custom_painter.dart';
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

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation;
  final _fireStore = FirebaseFirestore.instance;
  CalendarController _calendarController;
  Map<DateTime, List<dynamic>> _events;
  List<dynamic> _onSelectedDay;
  int t = 5, a = 2;
  String name = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _calendarController = CalendarController();
    _events = {};
    _onSelectedDay = [];
    WidgetsBinding.instance.addPostFrameCallback((_) => addEvents(context));
    controller = AnimationController(
      duration: Duration(
        seconds: 2,
      ),
      vsync: this,
    );
    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.bounceOut,
    );
    controller.forward();

    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView(children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.all(10.0),
                child: TableCalendar(
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  formatAnimation: FormatAnimation.slide,
                  events: _events,
                  calendarController: _calendarController,
                  initialCalendarFormat: CalendarFormat.twoWeeks,
                  builders: CalendarBuilders(
                    markersBuilder: (context, date, events, holiday) {
                      final children = <Widget>[];

                      if (events.isNotEmpty) {
                        children.add(Positioned(
                            child: _buildEventsmarker(date, events)));
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
              SizedBox(
                height: 20.0,
              ),
              Text(
                "Attendance Pie Chart",
                style: TextStyle(
                    color: Colors.lightBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0),
              ),
              SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      RichText(
                        text: TextSpan(
                            text: "⨷ ",
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                  text: "Present:-$a",
                                  style: TextStyle(color: Colors.green)),
                            ]),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      RichText(
                        text: TextSpan(
                            text: "⨷ ",
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                  text: "Absent:-${t - a}",
                                  style: TextStyle(color: Colors.red)),
                            ]),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Text(
                        "⨷ Total:-${t}",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  SizedBox(
                    width: 30.0,
                  ),
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          height: animation.value * 180,
                          width: animation.value * 180,
                          decoration:
                              BoxDecoration(shape: BoxShape.circle, boxShadow: [
                            BoxShadow(
                                spreadRadius: -1,
                                blurRadius: 8,
                                offset: Offset(4, 4),
                                color: Colors.black38),
                            BoxShadow(
                                spreadRadius: -10,
                                blurRadius: 17,
                                offset: Offset(-5, -5),
                                color: Colors.white),
                          ]),
                          padding: EdgeInsets.all(20.0),
                          child: CustomPaint(
                            painter: StudentPainter(total: t, present: a),
                          ),
                        ),
                        Positioned(
                          bottom: 65,
                          right: 65,
                          child: Center(
                              child: Container(
                            height: animation.value * 50,
                            width: animation.value * 50,
                            child: Center(
                              child: Text(
                                "${(a * 100 / t).toStringAsFixed(0)}%",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue),
                              ),
                            ),
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      spreadRadius: -1,
                                      blurRadius: 8,
                                      offset: Offset(3, 3),
                                      color: Colors.black54)
                                ],
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30.0)),
                          )),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _calendarController.dispose();
    controller.dispose();
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

  Future<void> addEvents(BuildContext context) async {
    t = 0;
    a = 0;
    if (widget.studentID == null) {
      var data = await _fireStore
          .collection("attendanceData")
          .where("professorID", isEqualTo: widget.professorID)
          .where("studentID", isEqualTo: widget.currentUserID)
          .get();
      setState(() {
        for (var d in data.docs) {
          t = t + 1;
          name = d.data()["professorName"];
          if (d.data()["present"] == false) {
            Timestamp t = d.data()["date"];
            DateTime dt = t.toDate();
            _events[dt] = [
              "You did not attend ${d.data()["professorName"]}'s lecture on this day"
            ];
          } else {
            a = a + 1;
          }
        }
      });
    } else {
      var data = await _fireStore
          .collection("attendanceData")
          .where("professorID", isEqualTo: widget.currentUserID)
          .where("studentID", isEqualTo: widget.studentID)
          .get();
      setState(() {
        for (var d in data.docs) {
          t = t + 1;
          name = d.data()["studentName"];
          if (d.data()["present"] == false) {
            Timestamp t = d.data()["date"];
            DateTime dt = t.toDate();
            _events[dt] = [
              "This student did not attend ${d.data()["professorName"]}'s lecture on this day"
            ];
          } else {
            a = a + 1;
          }
        }
      });
    }
  }
}
