import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:attendace_app/constantas.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final String branch;
  final String enrollNo;
  final String mobileNo;
  final String name;
  final String year;
  final String username;
  final bool isStudent;
  final String id;
  final String imageURL;
  final String status;

  ProfileScreen(
      {this.enrollNo,
      this.mobileNo,
      this.branch,
      this.year,
      this.name,
      this.username,
      this.isStudent,
      this.id,
      this.imageURL,
      this.status});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File _file;
  final picker = ImagePicker();
  final _fireStore = FirebaseFirestore.instance;
  String downloadedUR;
  bool loading = false;
  bool isShow = true;

  @override
  void initState() {
    // TODO: implement initState
    if (widget.imageURL != "no URL") {
      downloadedUR = widget.imageURL;
    }
    isShow = isItOrNot(widget.status);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            color: Colors.blue,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.30,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  gradient: LinearGradient(
                      tileMode: TileMode.repeated,
                      colors: [
                        Colors.blueAccent,
                        Colors.lightBlue,
                        Colors.blue
                      ])),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          color: Colors.white,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 12.0),
                          child: Text(
                            "Profile",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25.0,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: downloadedUR == null
                          ? GestureDetector(
                              onTap: () async {
                                await pickPicture();
                              },
                              child: CircleAvatar(
                                backgroundImage: ExactAssetImage(
                                  "assets/images/college_logo.jpg",
                                ),
                                radius: 55.0,
                              ),
                            )
                          : loading
                              ? CircularProgressIndicator(
                                  backgroundColor: Colors.white,
                                )
                              : GestureDetector(
                                  onTap: () async {
                                    await pickPicture();
                                  },
                                  child: CircleAvatar(
                                    radius: 55.0,
                                    backgroundImage: NetworkImage(
                                      downloadedUR,
                                    ),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                    ),
                    Text(
                      widget.name,
                      style: kLabaleStyle,
                    ),
                    SizedBox(
                      height: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          !isShow
              ? Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "username",
                              style: kInformationLableStyle,
                            ),
                            Text(
                              widget.username,
                              style: kInformationStyle,
                            )
                          ],
                        ),
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Status",
                              style: kInformationLableStyle,
                            ),
                            Text(
                              widget.status,
                              style: kInformationStyle,
                            )
                          ],
                        ),
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Mobile No.",
                              style: kInformationLableStyle,
                            ),
                            Text(
                              widget.mobileNo,
                              style: kInformationStyle,
                            )
                          ],
                        ),
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                final AndroidIntent intent = AndroidIntent(
                                    action: 'action_view',
                                    data: Uri.encodeFull(
                                        'http://www.lecm.cteguj.in/'),
                                    package: 'com.android.chrome');
                                intent.launch();
                              },
                              child: Text(
                                "About us",
                                style: kInformationStyle,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "username",
                              style: kInformationLableStyle,
                            ),
                            Text(
                              widget.username,
                              style: kInformationStyle,
                            )
                          ],
                        ),
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Mobile No.",
                              style: kInformationLableStyle,
                            ),
                            Text(
                              widget.mobileNo,
                              style: kInformationStyle,
                            )
                          ],
                        ),
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Branch",
                              style: kInformationLableStyle,
                            ),
                            Text(
                              widget.branch,
                              style: kInformationStyle,
                            )
                          ],
                        ),
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Enrollment No.",
                              style: kInformationLableStyle,
                            ),
                            Text(
                              widget.enrollNo,
                              style: kInformationStyle,
                            )
                          ],
                        ),
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Year",
                              style: kInformationLableStyle,
                            ),
                            Text(
                              widget.year,
                              style: kInformationStyle,
                            )
                          ],
                        ),
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                if (Platform.isAndroid) {
                                  print("In Android");
                                  final AndroidIntent intent = AndroidIntent(
                                      action: 'action_view',
                                      data: Uri.encodeFull(
                                          'http://www.lecm.cteguj.in/'),
                                      package: 'com.android.chrome');
                                  await intent.launch();
                                } else {
                                  print("Not Compitable");
                                }
                              },
                              child: Text(
                                "About us",
                                style: kInformationStyle,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Future<void> pickPicture() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _file = File(pickedFile.path);

        uploadImage(_file);
      } else {
        _file = null;
      }
    });
  }

  Future<void> uploadImage(File file) async {
    setState(() {
      loading = true;
    });
    try {
      await firebase_storage.FirebaseStorage.instance
          .ref("UserProfilePhotos/${widget.name}.png")
          .putFile(file)
          .then((value) {
        Fluttertoast.showToast(
            msg: "Updated Profile Successfully",
            toastLength: Toast.LENGTH_LONG,
            timeInSecForIosWeb: 1,
            textColor: Colors.white,
            fontSize: 16.0);
        setState(() {
          loading = false;
        });
      });
      retrevieImage();
    } catch (e) {
      print("Error:-------" + e);
    }
  }

  Future<void> retrevieImage() async {
    setState(() {
      loading = true;
    });
    try {
      String tDownloadedUR = await firebase_storage.FirebaseStorage.instance
          .ref('UserProfilePhotos/${widget.name}.png')
          .getDownloadURL();

      await _fireStore
          .collection("users")
          .doc(widget.id)
          .update({"imageURL": tDownloadedUR}).then((value) {
        setState(() {
          loading = false;
        });
      });

      setState(() {
        downloadedUR = tDownloadedUR;
      });
    } catch (e) {
      print("Error Retrive:----------" + e);
    }
  }

  bool isItOrNot(String status) {
    if (status == null) {
      return true;
    }
    return false;
  }
}
