import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../main.dart';

class NoInternet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset("assets/lotties/no_internet_connection.json"),
          FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              color: Colors.lightBlue,
              onPressed: () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => MyApp()));
              },
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Text("Try Again"),
              ))
        ],
      ),
    ));
  }
}
