import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:attendace_app/screens/login_screen.dart';
import 'package:attendace_app/screens/student_home_screen.dart';
import 'package:attendace_app/screens/year_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _fireStore = FirebaseFirestore.instance;

  final _auth = FirebaseAuth.instance;

  bool isStudent, isUserLogIn;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUser();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: AnimatedSplashScreen(
          splash: Container(
              height: 300.0,
              width: 300.0,
              child: Image.asset(
                "assets/images/college_logo.jpg",
              )),
          nextScreen: nextScreen(),
          backgroundColor: Colors.white,
          duration: 2000,
          splashTransition: SplashTransition.sizeTransition,
        ));
  }

  checkUser() async {
    if (_auth.currentUser != null) {
      isUserLogIn = true;
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

  Widget nextScreen() {
    if (isUserLogIn == true && isStudent == true) {
      return StudentHomeScreen();
    } else if (isUserLogIn == true) {
      return YearScreen();
    } else {
      return LoginScreen();
    }
  }
}
