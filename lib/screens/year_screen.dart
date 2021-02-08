import 'package:attendace_app/model/checking_data.dart';
import 'package:attendace_app/screens/profile_screen.dart';
import 'package:attendace_app/screens/student_home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'add_new_professor.dart';
import 'add_new_student.dart';
import 'login_screen.dart';

class YearScreen extends StatefulWidget {
  @override
  _YearScreenState createState() => _YearScreenState();
}

class _YearScreenState extends State<YearScreen> {
  final _auth = FirebaseAuth.instance.currentUser;
  List<String> userList;

  @override
  Widget build(BuildContext context) {
    userList = _auth.email.toString().split("@");
    CheckingData c = CheckingData();
    c.checkingData();
    c.workManager();
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              RaisedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProfileScreen()));
                },
                child: ListTile(
                  subtitle: Row(
                    children: [
                      Text("See your profile"),
                      Icon(Icons.keyboard_arrow_right),
                    ],
                  ),
                  title: Text(
                    userList[0],
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontSize: 22.0,
                    ),
                  ),
                  trailing: Container(
                    padding: EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40.0),
                        color: Colors.lightBlueAccent),
                    child: Icon(
                      Icons.person,
                      size: 30.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Divider(
                height: 2.0,
                thickness: 2.0,
                color: Colors.blue,
              ),
              ListTile(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddNewStudent()));
                },
                title: Row(
                  children: [
                    Text(
                      "Add New Student",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontSize: 15.0,
                      ),
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    Icon(Icons.person_add)
                  ],
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddProfessorScreen()));
                },
                title: Row(
                  children: [
                    Text(
                      "Add New Professor",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontSize: 15.0,
                      ),
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    Icon(Icons.person_add_alt_1_outlined)
                  ],
                ),
              ),
              ListTile(
                onTap: () async {
                  await FirebaseAuth.instance.signOut();

                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                },
                title: Row(
                  children: [
                    Text(
                      "Logout",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontSize: 15.0,
                      ),
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    Icon(Icons.logout)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text("Year List"),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => StudentHomeScreen(
                              index: 1,
                            )));
              },
              tileColor: Colors.lightBlueAccent,
              leading: Image.asset("assets/images/one.jpg"),
              title: Text(
                "First Year Student",
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => StudentHomeScreen(
                              index: 2,
                            )));
              },
              tileColor: Colors.lightBlueAccent,
              leading: Image.asset("assets/images/two.jpg"),
              title: Text(
                "Second Year Student",
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => StudentHomeScreen(
                              index: 3,
                            )));
              },
              tileColor: Colors.lightBlueAccent,
              leading: Image.asset("assets/images/three.jpg"),
              title: Text(
                "Third Year Student",
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => StudentHomeScreen(
                              index: 4,
                            )));
              },
              tileColor: Colors.lightBlueAccent,
              leading: Image.asset("assets/images/four.jpg"),
              title: Text(
                "Final Year Student",
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
