import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:attendace_app/screens/login_screen.dart';
import 'package:attendace_app/screens/no_internet.dart';
import 'package:attendace_app/screens/student_home_screen.dart';
import 'package:attendace_app/screens/year_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:workmanager/workmanager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Workmanager.initialize(callbackDispatcher);

  runApp(MyApp());
}

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) {
    // initialise the plugin of flutterlocalnotifications.
    FlutterLocalNotificationsPlugin flip =
        new FlutterLocalNotificationsPlugin();

    // app_icon needs to be a added as a drawable
    // resource to the Android head project.
    var android = new AndroidInitializationSettings('college_logo');
    var IOS = new IOSInitializationSettings();

    // initialise settings for both Android and iOS device.
    var settings = new InitializationSettings(android: android, iOS: IOS);
    flip.initialize(settings);
    _showNotificationWithDefaultSound(flip, task);
    return Future.value(true);
  });
}

Future _showNotificationWithDefaultSound(flip, String data) async {
  // Show a notification after every 15 minute with the first
  // appearance happening a minute after invoking the method
  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'My ID', 'Harsh Sureja', 'Unknown',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      visibility: NotificationVisibility.public,
      sound: RawResourceAndroidNotificationSound('notification_sound'));
  var iOSPlatformChannelSpecifics = new IOSNotificationDetails();

  // initialise channel platform for both Android and iOS device.
  var platformChannelSpecifics = new NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
  await flip.show(0, 'Attendance App', data, platformChannelSpecifics);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _fireStore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool isStudent, isUserLogIn, connectivity = false;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkConnectivity(context);
    });
    super.initState();
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
          curve: Curves.bounceIn,
          splash: Hero(
            tag: 'college',
            child: Container(
                height: 300.0,
                width: 300.0,
                child: Image.asset(
                  "assets/images/college_logo.jpg",
                )),
          ),
          nextScreen: FutureBuilder(
            initialData: CircularProgressIndicator(),
            builder: (context, initialData) {
              if (connectivity) {
                return nextScreen();
              } else {
                return NoInternet();
              }
            },
            future: checkUser(context),
          ),
          backgroundColor: Colors.white,
          duration: 2000,
          splashTransition: SplashTransition.fadeTransition,
        ));
  }

  checkUser(BuildContext context) async {
    if (_auth.currentUser != null) {
      isUserLogIn = true;
      final userF = await _fireStore
          .collection("users")
          .where("username", isEqualTo: _auth.currentUser.email)
          .get();
      print(userF.docs.length);
      for (var user in userF.docs) {
        if (user.data()["username"] == _auth.currentUser.email.toString()) {
          if (user.data()["isStudent"]) {
            isStudent = true;
            print(isStudent);
          } else {
            isStudent = false;
          }
        }
      }
    }
  }

  checkConnectivity(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        connectivity = false;
      });

      Fluttertoast.showToast(
          msg: "No Internet Connection",
          backgroundColor: Colors.red,
          toastLength: Toast.LENGTH_LONG);
    } else {
      setState(() {
        connectivity = true;
      });
    }
  }

  Widget nextScreen() {
    print("UserLogin" + isUserLogIn.toString());
    print("Student" + isStudent.toString());
    if (isUserLogIn == true && isStudent == true) {
      return StudentHomeScreen();
    } else if (isUserLogIn == true && isStudent == false) {
      return YearScreen();
    } else {
      return LoginScreen();
    }
  }
}
