import 'package:attendace_app/model/checking_data.dart';
import 'package:attendace_app/screens/login_screen.dart';
import 'package:attendace_app/screens/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'calener_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  final index;
  StudentHomeScreen({this.index = 0});

  @override
  _StudentHomeScreenState createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  var auth = FirebaseAuth.instance;
  var fireStore = FirebaseFirestore.instance;
  bool isStudent = true;
  String currentUser;

  bool notification = true;

  String branchP;
  String enrollNoP;
  String mobileNoP;
  String statusP;
  String nameP;
  String yearP;
  String usernameP;
  bool isStudentP;
  String id;
  String imageURL;
  bool loading = true;
  Map<String, int> presentCount = {};
  Map<String, int> totalCount = {};
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentUser = auth.currentUser.email;
    checkStudent();
  }

  @override
  Widget build(BuildContext context) {
    presentCount.clear();
    totalCount.clear();

    List<String> userN = currentUser.split("@");

    return Scaffold(
      appBar: isStudent
          ? AppBar(title: Text(userN[0]), actions: [
              IconButton(
                  icon: Icon(Icons.login_outlined),
                  onPressed: () async {
                    setState(() {
                      loading = false;
                    });
                    await auth.signOut();
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  }),
              IconButton(
                  icon: Icon(Icons.person),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                                  branch: branchP,
                                  enrollNo: enrollNoP,
                                  mobileNo: mobileNoP,
                                  name: nameP,
                                  year: yearP,
                                  isStudent: isStudentP,
                                  username: usernameP,
                                  id: id,
                                  imageURL: imageURL,
                                  status: statusP,
                                )));
                  }),
            ])
          : null,
      body: !loading
          ? Center(child: CircularProgressIndicator())
          : Visibility(
              visible: loading,
              child: StreamBuilder<QuerySnapshot>(
                builder: (context, snapshot) {
                  presentCount.clear();
                  totalCount.clear();
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final users = snapshot.data.docs;
                  List<String> sUserName = [];
                  List<String> sUserEnrollNo = [];
                  List<int> sUserYear = [];
                  List<String> sID = [];
                  List<String> sImageURL = [];

                  List<String> pFirstName = [];
                  List<String> pStatus = [];
                  List<String> pImageURL = [];
                  List<String> pID = [];

                  for (var user in users) {
                    if (user.data()["username"] ==
                        auth.currentUser.email.toString()) {
                      branchP = user.data()["branch"];
                      enrollNoP = user.data()["enrollNo"];
                      mobileNoP = user.data()["mobileNo"];
                      nameP = user.data()["name"];
                      yearP = user.data()["year"].toString();
                      isStudentP = user.data()["isStudent"];
                      usernameP = user.data()["username"];
                      id = user.data()["id"];
                      imageURL = user.data()["imageURL"];
                      statusP = user.data()["status"];

                      if (!user.data()["isStudent"]) {
                        isStudent = false;
                      }
                    }
                  }

                  if (isStudent == false) {
                    for (var user in users) {
                      if (user.data()["isStudent"] == true &&
                          user.data()["year"] == widget.index) {
                        sUserName.add(user.data()["name"]);
                        sUserEnrollNo.add(user.data()["enrollNo"]);
                        sUserYear.add(user.data()["year"]);
                        sID.add(user.data()["id"]);
                        sImageURL.add(user.data()["imageURL"]);
                      }
                    }
                  } else {
                    for (var user in users) {
                      if (user.data()["isStudent"] == false) {
                        pFirstName.add(user.data()["name"]);
                        pStatus.add(user.data()["status"]);
                        pImageURL.add(user.data()["imageURL"]);
                        pID.add(user.data()["id"]);
                      }
                    }
                  }

                  if (isStudent == false) {
                    return ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            elevation: 3.0,
                            shadowColor: Colors.grey,
                            color: Colors.lightBlueAccent,
                            child: Dismissible(
                              key: Key(id),
                              onDismissed: (direction) async {
                                String _id;
                                if (direction == DismissDirection.startToEnd) {
                                  var attendanceData = await fireStore
                                      .collection("attendanceData")
                                      .add({
                                    "present": true,
                                    "studentName": sUserName[index],
                                    "date": DateTime.now(),
                                    "documentID": "no id",
                                    "professorID": id,
                                    "professorName": nameP,
                                    "studentID": sID[index],
                                    "StudentYear": widget.index.toString()
                                  });

                                  _id = attendanceData.id;

                                  await fireStore
                                      .collection("attendanceData")
                                      .doc(_id)
                                      .update({
                                    "documentID": _id
                                  }).whenComplete(() => Fluttertoast.showToast(
                                          msg: "Present:- ${sUserName[index]}",
                                          toastLength: Toast.LENGTH_SHORT,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.green,
                                          textColor: Colors.white,
                                          fontSize: 16.0));
                                } else {
                                  var attendanceData = await fireStore
                                      .collection("attendanceData")
                                      .add({
                                    "present": false,
                                    "studentName": sUserName[index],
                                    "date": DateTime.now(),
                                    "documentID": "no id",
                                    "professorID": id,
                                    "professorName": nameP,
                                    "studentID": sID[index],
                                    "StudentYear": widget.index.toString()
                                  });

                                  _id = attendanceData.id;

                                  await fireStore
                                      .collection("attendanceData")
                                      .doc(_id)
                                      .update({
                                    "documentID": _id
                                  }).whenComplete(() => Fluttertoast.showToast(
                                          msg: "Absent:- ${sUserName[index]}",
                                          toastLength: Toast.LENGTH_SHORT,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0));
                                }
                              },
                              secondaryBackground: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.symmetric(horizontal: 30.0),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                              background: Container(
                                color: Colors.green,
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.symmetric(horizontal: 30.0),
                                child: Icon(
                                  Icons.done,
                                  color: Colors.white,
                                ),
                              ),
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CalendarScreen(
                                                currentUserID: id,
                                                studentID: sID[index],
                                              )));
                                },
                                title: Text(sUserName[index] + ""),
                                subtitle: Text(sUserEnrollNo[index] + ""),
                                leading: Container(
                                  height: 50.0,
                                  width: 50.0,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25.0),
                                      color: Colors.grey),
                                  child: Center(
                                      child: sImageURL[index] != "no URL"
                                          ? CircleAvatar(
                                              radius: 35.0,
                                              backgroundImage: NetworkImage(
                                                  sImageURL[index]),
                                              backgroundColor:
                                                  Colors.transparent,
                                            )
                                          : Icon(Icons.person)),
                                ),
                                tileColor: Colors.lightBlueAccent,
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: sUserName.length,
                    );
                  } else {
                    CheckingData c = CheckingData();

                    c.workManager();
                    return ListView.separated(
                        separatorBuilder: (context, index) => Divider(
                              indent: 2.0,
                              endIndent: 2.0,
                              color: Colors.blueAccent,
                            ),
                        itemCount: pFirstName.length,
                        itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CalendarScreen(
                                                currentUserID: id,
                                                professorID: pID[index],
                                              )));
                                },
                                title: Text(pFirstName[index]),
                                subtitle: Text(pStatus[index]),
                                leading: pImageURL[index] == "no URL"
                                    ? Icon(
                                        Icons.person,
                                        color: Colors.black,
                                        size: 35.0,
                                      )
                                    : CircleAvatar(
                                        radius: 35.0,
                                        backgroundImage: NetworkImage(
                                          pImageURL[index],
                                        ),
                                        backgroundColor: Colors.transparent,
                                      ),
                              ),
                            ));
                  }
                },
                stream: fireStore.collection("users").snapshots(),
              ),
            ),
    );
  }

  checkStudent() async {
    var doc = await fireStore
        .collection("users")
        .where("username", isEqualTo: currentUser.toString())
        .get();

    for (var d in doc.docs) {
      isStudent = d.data()["isStudent"];

      print("isStuent" + isStudent.toString());
    }
  }
}
