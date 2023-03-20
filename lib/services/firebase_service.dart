import 'package:evacuation_project/domain/model/division.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/model/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FirebaseService {
  final firebaseInstance = FirebaseFirestore.instance;
  User? currentUser;
  List<Division> divisionsList = [];
  Future<String?> login({
    required String userId,
    required String userPIN,
  }) async {
    List<User> userList = [];
    await firebaseInstance
        .collection('WorkersList')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        userList.add(User.fromDocument(doc));
      }
    });

    if (userList.isNotEmpty) {
      for (var element in userList) {
        if (element.userId == userId && element.userPIN == userPIN) {
          currentUser = element;
        }
      }
      if (currentUser != null) {
        var storage = const FlutterSecureStorage();
        await storage.write(key: 'userID', value: userId);
        await storage.write(key: 'userPIN', value: userPIN);
        return 'Zalogowano';
      }
    }
    return 'Błąd logowania';
  }

  String getUsername() {
    return currentUser?.userName ?? '';
  }

  Future<List<Division>> getDivisionsList() async {
    divisionsList = [];
    await firebaseInstance
        .collection('Divisions')
        .where('divisionName', isEqualTo: 'Dział Główny')
        .get()
        .then((QuerySnapshot querySnapshot) async {
      for (var doc in querySnapshot.docs) {
        divisionsList.add(await Division.fromDocument(doc));
      }
    });
    return divisionsList;
  }

  Future<List<Division>> resetEvacuationList() async {
    await FirebaseFirestore.instance
        .collection('WorkersList')
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.update({
          'userStatus': 'not_evacuated',
        });
      }
    });

    return getDivisionsList();
  }

  Future<void> updateUserStatus() async {
    await FirebaseFirestore.instance
        .collection('WorkersList')
        .where('userName', isEqualTo: currentUser!.userName)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.update({
          'userStatus': 'evacuated',
        });
      }
    });
  }
}
