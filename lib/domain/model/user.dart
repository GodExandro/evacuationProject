import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String userId;
  String userPIN;
  String userName;
  String userStatus;
  String userPermission;

  User(
      {required this.userId,
      required this.userPIN,
      required this.userName,
      required this.userStatus,
      required this.userPermission});

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      userId: doc.data().toString().contains('userId') ? doc.get('userId') : '',
      userPIN:
          doc.data().toString().contains('userPIN') ? doc.get('userPIN') : '',
      userName:
          doc.data().toString().contains('userName') ? doc.get('userName') : '',
      userStatus: doc.data().toString().contains('userStatus')
          ? doc.get('userStatus')
          : '',
      userPermission: doc.data().toString().contains('userPermission')
          ? doc.get('userPermission')
          : '',
    );
  }
}
