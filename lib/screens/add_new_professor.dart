import 'package:attendace_app/model/status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class AddProfessorScreen extends StatefulWidget {
  @override
  _AddProfessorScreenState createState() => _AddProfessorScreenState();
}

class _AddProfessorScreenState extends State<AddProfessorScreen> {
  String st, firstName, lastName, mobileNo;
  final _fireStore = FirebaseFirestore.instance;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    st = status[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: Icon(Icons.done),
              onPressed: () async {
                setState(() {
                  loading = true;
                });
                await addUser(firstName, lastName, mobileNo, st);
              })
        ],
        elevation: 0.0,
        title: Text("Add New Professor"),
      ),
      body: ModalProgressHUD(
        inAsyncCall: loading,
        child: ListView(
          children: [
            Container(
              height: 100.0,
              width: 150.0,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(50.0),
                      bottomLeft: Radius.circular(50.0)),
                  color: Colors.blue),
              child: Lottie.network(
                "https://assets3.lottiefiles.com/packages/lf20_xrC7ik.json",
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (string) {
                      firstName = string;
                    },
                    decoration: InputDecoration(
                        labelText: "Professor First Name",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (string) {
                      lastName = string;
                    },
                    decoration: InputDecoration(
                        labelText: "Professor Last Name",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (string) {
                      mobileNo = string;
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: "Professor Mobile No.",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0))),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                "# Select Student Status:",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 150.0, left: 15.0),
              child: DropdownButton(
                items: dropdownStatus(),
                onChanged: (string) {
                  setState(() {
                    st = string;
                  });
                },
                value: st,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem> dropdownStatus() {
    List<DropdownMenuItem> items = [];

    for (var s in status) {
      items.add(DropdownMenuItem(
        child: Text(s),
        value: s,
      ));
    }

    return items;
  }

  Future<void> addUser(
      String firstName, String lastName, String mobileNo, String status) async {
    if (firstName != null &&
        lastName != null &&
        mobileNo != null &&
        status != null) {
      var professor = await _fireStore.collection("users").add({
        "name": firstName + " " + lastName,
        "isStudent": false,
        "mobileNo": mobileNo,
        "status": status,
        "username": firstName.toLowerCase() + "@email.com",
        "imageURL": "no URL",
        "id": "no id"
      });
      String _id = professor.id;

      await _fireStore.collection("users").doc(_id).update({"id": _id}).then(
          (value) => Fluttertoast.showToast(
              msg: "Professor Added Successfully",
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
