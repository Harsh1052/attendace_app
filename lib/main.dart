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
    // CheckingData c = CheckingData();
    // c.checkingData();

    _showNotificationWithDefaultSound(flip, task);
    print("In If Loop");

    // _showNotificationWithDefaultSound(flip, task);
    return Future.value(true);
  });
}

Future _showNotificationWithDefaultSound(flip, String data) async {
  // Show a notification after every 15 minute with the first
  // appearance happening a minute after invoking the method
  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'your channel id', 'your channel name', 'your channel description',
      importance: Importance.max, priority: Priority.high);
  var iOSPlatformChannelSpecifics = new IOSNotificationDetails();

  // initialise channel platform for both Android and iOS device.
  var platformChannelSpecifics = new NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
  await flip.show(0, 'Attendance App', data, platformChannelSpecifics,
      payload: 'Default_Sound');
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
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkUser(context);
      checkConnectivity(context);
    });
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
          nextScreen: connectivity ? nextScreen() : NoInternet(),
          backgroundColor: Colors.white,
          duration: 2000,
          splashTransition: SplashTransition.sizeTransition,
        ));
  }

  Future<void> checkUser(BuildContext context) async {
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

  Future<void> checkConnectivity(BuildContext context) async {
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
    if (isUserLogIn == true && isStudent == true) {
      return StudentHomeScreen();
    } else if (isUserLogIn == true) {
      return YearScreen();
    } else {
      return LoginScreen();
    }
  }
}
