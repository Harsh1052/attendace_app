import 'package:attendace_app/screens/student_home_screen.dart';
import 'package:attendace_app/screens/year_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool visibleKey = true;
  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;
  String enrollment;
  String password;
  bool isStudent;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    setState(() {
      visibleKey = MediaQuery.of(context).viewInsets.bottom == 0 ? true : false;
    });

    return Scaffold(
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: loading,
          child: Stack(
            children: [
              Positioned(
                right: MediaQuery.of(context).size.width / 2 - 75.0,
                child: Column(
                  children: [
                    Container(
                      height: 150.0,
                      width: 150.0,
                      child: Lottie.network(
                          "https://assets6.lottiefiles.com/packages/lf20_goeb1fbr.json"),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      "Professor Login",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0,
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                top: 200.0,
                left: 15.0,
                right: 15.0,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: TextField(
                        onTap: () {
                          if (MediaQuery.of(context).viewInsets.bottom == 0) {
                            setState(() {
                              visibleKey = false;
                            });
                          }
                        },
                        onChanged: (e) {
                          enrollment = e;
                        },
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            labelStyle: TextStyle(color: Colors.black),
                            labelText: "Professor/Student Username",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: TextField(
                        obscureText: true,
                        onTap: () {
                          if (MediaQuery.of(context).viewInsets.bottom == 0) {
                            setState(() {
                              visibleKey = false;
                            });
                          }
                        },
                        onChanged: (p) {
                          password = p;
                        },
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            labelStyle: TextStyle(color: Colors.black),
                            labelText: "Password",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            )),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          loading = true;
                        });
                        if (enrollment != null && password != null) {
                          try {
                            var user = await _auth.signInWithEmailAndPassword(
                                email: enrollment, password: password);

                            if (user != null) {
                              await checkUser();
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => isStudent
                                          ? StudentHomeScreen()
                                          : YearScreen()));
                            }
                          } on FirebaseAuthException catch (e) {
                            print(e.message);
                            setState(() {
                              loading = false;
                            });
                            Fluttertoast.showToast(
                                msg: e.message,
                                toastLength: Toast.LENGTH_LONG,
                                timeInSecForIosWeb: 1,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          }
                        } else {
                          setState(() {
                            loading = false;
                          });
                          Fluttertoast.showToast(
                              msg: "Enter all field",
                              toastLength: Toast.LENGTH_LONG,
                              timeInSecForIosWeb: 1,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        width: MediaQuery.of(context).size.width - 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.0),
                          color: Colors.black26,
                        ),
                        child: Text(
                          "Login",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.w400),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                  bottom: 10.0,
                  left: 20.0,
                  right: 20.0,
                  child: Visibility(
                    visible: visibleKey,
                    child: Center(
                      child: Container(
                        width: 300.0,
                        child: Image.asset("assets/images/college_logo.jpg"),
                      ),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  checkUser() async {
    if (_auth.currentUser != null) {
      final userF = await _fireStore.collection("users").get();

      for (var user in userF.docs) {
        if (user.data()["username"] == _auth.currentUser.email.toString()) {
          if (user.data()["isStudent"]) {
            isStudent = true;
          } else {
            isStudent = false;
          }
        }
      }
    }
  }
}
