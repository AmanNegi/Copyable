
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  String userName;
  String email;
  String uid;
  late String referenceId;

  UserModel({
    required this.email,
    required this.userName,
    required this.uid,
  });

  factory UserModel.fromJson(Map<String, dynamic> map) => UserModel(
        email: map['email'],
        userName: map['username'],
        uid: map['uid'],
      );

  factory UserModel.fromUser(User user) => UserModel(
        email: user.email ?? "NIL",
        userName: user.displayName ?? "NIL",
        uid: user.uid,
      );

  factory UserModel.fromSnapshot(DocumentSnapshot data) {
    UserModel value = UserModel.fromJson(data.data() as Map<String, dynamic>);
    value.referenceId = data.reference.id;
    return value;
  }
  Map<String, dynamic> toJson() => {
        "username": userName,
        'email': email,
        'uid': uid,
      };

  @override
  String toString() {
    return "{username: $userName, email: $email}";
  }
}

bool isTheSameUserModel(UserModel one, UserModel another) {
  return (one.email == another.email && one.userName == another.userName);
}
