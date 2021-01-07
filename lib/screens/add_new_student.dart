import 'dart:ui';

import 'package:attendace_app/model/branches.dart';
import 'package:attendace_app/model/years.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class AddNewStudent extends StatefulWidget {
  @override
  _AddNewStudentState createState() => _AddNewStudentState();
}

class _AddNewStudentState extends State<AddNewStudent> {
  String branches;
  String selectedYear;
  String fullName;
  String enrollNo;
  String mobileNo;
  final auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    branches = branch[0];
    selectedYear = years[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text("Add New Student"),
        actions: [
          IconButton(
              icon: Icon(Icons.done),
              onPressed: () async {
                setState(() {
                  loading = true;
                });

                await addStudentData();
              })
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: loading,
        child: ListView(
          children: [
            Container(
              height: 100.0,
              width: 100.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0)),
                color: Colors.blue,
              ),
              child: Lottie.network(
                  "https://assets9.lottiefiles.com/packages/lf20_u0w6fbdq.json"),
            ),
            SizedBox(
              height: 10.0,
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (name) {
                      fullName = name;
                    },
                    decoration: InputDecoration(
                        labelText: "Student Full Name",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (eNo) {
                      enrollNo = eNo;
                    },
                    decoration: InputDecoration(
                        labelText: "Student Enrollment No",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (mNo) {
                      mobileNo = mNo;
                    },
                    decoration: InputDecoration(
                        labelText: "Student Mobile No",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0))),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                "# Select Student Branch",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 150.0, left: 15.0),
              child: DropdownButton(
                value: branches,
                items: dropDownBranch(),
                onChanged: (string) {
                  setState(() {
                    branches = string;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                "# Select Student Current Year",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 294.0, left: 15.0),
              child: DropdownButton(
                value: selectedYear,
                items: dropDownYear(),
                onChanged: (string) {
                  setState(() {
                    selectedYear = string;
                  });
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
              child: Text(
                "*Student email will be 180310xxxx29@email.com",
                style: TextStyle(color: Colors.blue[200]),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
              child: Text("*Student password will be student's mobile number",
                  style: TextStyle(color: Colors.blue[200])),
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem> dropDownBranch() {
    List<DropdownMenuItem> items = [];

    for (var item in branch) {
      items.add(DropdownMenuItem(
        value: item,
        child: Text(item),
      ));
    }
    return items;
  }

  List<DropdownMenuItem> dropDownYear() {
    List<DropdownMenuItem> yearsList = [];

    for (var year in years) {
      yearsList.add(DropdownMenuItem(
        child: Text(year),
        value: year,
      ));
    }
    return yearsList;
  }

  addStudentData() async {
    if (branches != null &&
        selectedYear != null &&
        fullName != null &&
        mobileNo != null &&
        enrollNo != null) {
      int iSelectedYear = int.parse(selectedYear);

      var student = await _fireStore.collection("users").add({
        "name": fullName,
        "branch": branches,
        "enrollNo": enrollNo,
        "mobileNo": mobileNo,
        "year": iSelectedYear,
        "username": "$enrollNo@email.com",
        "isStudent": true,
        "imageURL": "no URL"
      });

      String _id = student.id;

      await _fireStore.collection("users").doc(_id).update({"id": _id}).then(
          (value) => Fluttertoast.showToast(
              msg: "Student Added Successfully",
              toastLength: Toast.LENGTH_LONG,
              timeInSecForIosWeb: 1,
              textColor: Colors.white,
              fontSize: 16.0));

      Navigator.pop(context);
    } else {
      setState(() {
        loading = false;
      });

      Fluttertoast.showToast(
          msg: "Please Fill All Details",
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
