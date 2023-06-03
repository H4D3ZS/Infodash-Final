// ignore_for_file: avoid_web_libraries_in_flutter, avoid_function_literals_in_foreach_calls, unused_local_variable, import_of_legacy_library_into_null_safe

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_session/flutter_session.dart';

class User {
  final String id;
  final String email;
  final String password;
  final String userType;
  User(this.id, this.email, this.password, this.userType);

  Map<String, dynamic> toJson() =>
      {'id': id, 'email': email, 'password': password, 'userType': userType};

  static User fromJson(Map<String, dynamic> json) =>
      User(json['id'], json['email'], json['password'], json['userType']);

  Future<User> login() async {
    User loggedInUser = this;
    final users = await FirebaseFirestore.instance
        .collection('UserAccounts')
        .where('email', isEqualTo: email)
        .where('password', isEqualTo: password)
        .limit(1)
        .get();

    users.docs.forEach((element) {
      User data = fromJson(element.data());
      loggedInUser = data;
    });

    if (loggedInUser.id != "") {
      await FlutterSession().set("_id", loggedInUser.id);
    }

    // ignore: prefer_const_declarations
    return loggedInUser;
  }

  Future<String> register() async {
    final docUser = FirebaseFirestore.instance.collection('UserAccounts').doc();
    final user = User(docUser.id, email, password, userType);
    await docUser.set(user.toJson());
    return id;
  }
}
