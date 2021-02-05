import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workmanager/workmanager.dart';

class CheckingData {
  final _firestore = FirebaseFirestore.instance;
  String professorName = "unknown";
  String year = "unknown";

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
      "Attendance taken by" + professorName + " of " + year + " year",
      frequency: Duration(hours: 1),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }
}
