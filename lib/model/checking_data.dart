import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:workmanager/workmanager.dart';

class CheckingData {
  final _firestore = FirebaseFirestore.instance;
  String professorName = "unknown";
  String year = "unknown";
  String time = "unknown";

  Future<bool> checkingData() async {
    try {
      var last = await _firestore
          .collection("attendanceData")
          .orderBy("date", descending: true)
          .limit(1)
          .get();

      for (var i in last.docs) {
        professorName = i.data()["professorName"].toString();
        year = i.data()["StudentYear"];
        Timestamp timestamp = i.data()["date"];
        time = DateFormat("hh:mm a").format(timestamp.toDate()).toString();
        print("time===" + time);
      }

      if (professorName != ".") {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  void workManager() async {
    await checkingData();
    Workmanager.registerPeriodicTask(
      "4",
      professorName + " take " + year + " year attendance" + " At " + time,
      frequency: Duration(hours: 1),
      constraints: Constraints(
          //networkType: NetworkType.connected,
          ),
    );
  }
}
