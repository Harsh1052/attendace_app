import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../constantas.dart';

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

  ProfileScreen(
      {this.enrollNo,
      this.mobileNo,
      this.branch,
      this.year,
      this.name,
      this.username,
      this.isStudent,
      this.id,
      this.imageURL});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File _file;
  final picker = ImagePicker();
  final _fireStore = FirebaseFirestore.instance;
  String downloadedUR;
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.imageURL != "no URL") {
      downloadedUR = widget.imageURL;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlue])),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: downloadedUR == null
                    ? CircleAvatar(
                        backgroundImage: ExactAssetImage(
                          "assets/images/one.jpg",
                        ),
                        radius: 60.0,
                      )
                    : loading
                        ? CircularProgressIndicator(
                            backgroundColor: Colors.white,
                          )
                        : CircleAvatar(
                            radius: 60.0,
                            backgroundImage: NetworkImage(
                              downloadedUR,
                            ),
                            foregroundColor: Colors.white,
                          ),
              ),
              RaisedButton(
                color: Colors.blueAccent,
                onPressed: () async {
                  await pickPicture();
                },
                child: Text(
                  "Update Profile photo",
                  style: TextStyle(fontSize: 10.0),
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      "Username:",
                      style: kLableStyle,
                    ),
                    Text(
                      widget.username,
                      style: kInformationStyle.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      "Name:",
                      style: kLableStyle,
                    ),
                    Text(
                      widget.name,
                      style: kInformationStyle.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      "Mobile No.:",
                      style: kLableStyle,
                    ),
                    Text(
                      widget.mobileNo,
                      style: kInformationStyle.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  pickPicture() async {
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

  uploadImage(File file) async {
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
      retriveImage();
    } catch (e) {
      print("Error:-------" + e);
    }
  }

  retriveImage() async {
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
}
