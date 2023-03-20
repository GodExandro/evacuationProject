import 'package:evacuation_project/domain/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Division {
  String divisionName;
  List<Division> subDivision;
  List<User> workers;

  Division({
    required this.divisionName,
    required this.subDivision,
    required this.workers,
  });

  static Future<Division> fromDocument(DocumentSnapshot doc) async {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String divisionName = data['divisionName'];
    List<Division> subDivisions = [];
    List<User> workersList = [];

    if (data['subDivisions'] != null) {
      List<dynamic> subDivisionRefs = data['subDivisions'];
      subDivisions = await Future.wait(
        subDivisionRefs.map((subDivisionRef) async {
          DocumentSnapshot subDivisionDoc = await subDivisionRef.get();
          return Division.fromDocument(subDivisionDoc);
        }).toList(),
      );
    }

    if (data['workers'] != null) {
      List<dynamic> workersListRefs = data['workers'];
      workersList = await Future.wait(
        workersListRefs.map((workersListRef) async {
          DocumentSnapshot workersListDoc = await workersListRef.get();
          return User.fromDocument(workersListDoc);
        }).toList(),
      );
    }

    return Division(
      divisionName: divisionName, //String
      subDivision: subDivisions,
      workers: workersList, //String
    );
  }
}
